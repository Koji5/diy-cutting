import sys, traceback
from fastapi.responses import JSONResponse
from fastapi import FastAPI, Response
from io import StringIO
from pydantic import BaseModel
from typing import List, Literal, Optional, Tuple
from app.dxf_builder import build_dimensioned_dxf, build_cam_dxf
from app.pdf_export import dxf_to_pdf_bytes
from app.preview import build_base_svg
import fitz

Point = Tuple[float, float]

from ezdxf.fonts import fonts
try:
    fonts.build_system_font_cache()  # 一度作ればOK（数秒）
except Exception:
    pass

class Polyline(BaseModel):
    layer: str = "OUTER"
    closed: bool = True
    points: List[Point]

class Circle(BaseModel):
    layer: str = "DRILL"
    center: Point
    r: float

class Dimension(BaseModel):
    kind: Literal["linear","aligned"] = "linear"
    p1: Point
    p2: Point
    base: Optional[Point] = None
    distance: Optional[float] = None
    override: dict = {}

class DXFIn(BaseModel):
    polylines: List[Polyline] = []
    circles:   List[Circle]   = []
    dimensions: List[Dimension] = []
    title: Optional[str] = None

app = FastAPI(title="DXF Microservice")

@app.get("/debug/pdf_fonts")
def debug_pdf_fonts():
    from app.dxf_builder import build_dimensioned_dxf
    from app.pdf_export import dxf_to_pdf_bytes
    import fitz
    dummy = {
        "title": "板 100x50",
        "polylines": [{"layer":"OUTER","closed":True,"points":[[0,0],[100,0],[100,50],[0,50]]}],
        "circles": [],
        "dimensions": [],
    }
    doc = build_dimensioned_dxf(DXFIn(**dummy))
    pdf = dxf_to_pdf_bytes(doc, mm_per_unit=1.0)
    doc_pdf = fitz.open(stream=pdf, filetype="pdf")
    fonts = set(n[3] for n in doc_pdf[0].get_fonts(full=True))
    return {"fonts_on_page1": sorted(fonts)}

@app.get("/health")
def health():
    return {"ok": True}

@app.post("/dxf/dimensioned")
def dxf_dimensioned(payload: DXFIn):
    doc = build_dimensioned_dxf(payload)
    buf = StringIO()            # ← テキストIO
    doc.write(buf)
    data = buf.getvalue().encode("utf-8")  # ← bytes に変換
    return Response(content=data, media_type="application/dxf")

@app.post("/dxf/cam")
def dxf_cam(payload: DXFIn):
    doc = build_cam_dxf(payload)
    buf = StringIO()
    doc.write(buf)
    data = buf.getvalue().encode("utf-8")
    return Response(content=data, media_type="application/dxf")

@app.post("/pdf/drawing")
def pdf_from_dxf(payload: DXFIn):
    doc = build_dimensioned_dxf(payload)
    pdf_bytes = dxf_to_pdf_bytes(doc, mm_per_unit=1.0)
    return Response(content=pdf_bytes, media_type="application/pdf")

def pdf_to_png(pdf_bytes: bytes, width_px: int = 1000) -> bytes:
    doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    page = doc[0]
    zoom = width_px / page.rect.width
    mat = fitz.Matrix(zoom, zoom)
    pix = page.get_pixmap(matrix=mat, alpha=False)
    return pix.tobytes("png")

@app.post("/preview/base.svg")
def preview_base_svg(payload: DXFIn):
    svg = build_base_svg(payload)
    return Response(content=svg, media_type="image/svg+xml")

@app.post("/preview/dim.png")
def preview_dim_png(payload: DXFIn):
    doc = build_dimensioned_dxf(payload)
    pdf = dxf_to_pdf_bytes(doc, mm_per_unit=1.0)
    return Response(content=pdf_to_png(pdf, 1000), media_type="image/png")

@app.post("/preview/cam.png")
def preview_cam_png(payload: DXFIn):
    doc = build_cam_dxf(payload)
    pdf = dxf_to_pdf_bytes(doc, mm_per_unit=1.0)
    return Response(content=pdf_to_png(pdf, 1000), media_type="image/png")
