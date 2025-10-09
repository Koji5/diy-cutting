import ezdxf
from ezdxf.entities import Dimension
from ezdxf.math import Vec2

def _new_doc_mm():
    # R2010 + デフォルトDIMSTYLEを用意
    doc = ezdxf.new("R2010", setup=True)
    doc.units = ezdxf.units.MM  # mm運用
    # レイヤ定義（色はACI）
    for name, color in [
        ("OUTER", 7), ("INNER", 8), ("POCKET", 3), ("DRILL", 1),
        ("TEXT", 7), ("DIM", 2)
    ]:
        if name not in doc.layers:
            doc.layers.add(name, dxfattribs={"color": color})
    return doc

def _add_primitives(msp, payload):
    # ポリライン
    for pl in payload.polylines:
        lw = msp.add_lwpolyline(pl.points, format="xy", close=pl.closed,
                                dxfattribs={"layer": pl.layer})
        lw.closed = pl.closed
    # 円（穴）
    for c in payload.circles:
        msp.add_circle(c.center, c.r, dxfattribs={"layer": c.layer})

def _add_dimensions(msp, payload):
    for d in payload.dimensions:
        if d.kind == "linear":
            # base=寸法線上の一点（どこでも可）
            dim = msp.add_linear_dim(base=d.base, p1=d.p1, p2=d.p2, override=d.override)
            dim.render()  # 寸法ブロック生成（必須）
        else:  # aligned
            # p1-p2 に平行な寸法線を offset=distance で配置
            dim = msp.add_aligned_dim(p1=d.p1, p2=d.p2, distance=d.distance, override=d.override)
            # aligned は内部で描画まで行われるが、明示 render を呼んでもOK
            try:
                dim.render()
            except Exception:
                pass
        # レイヤを DIM に寄せたい場合：
        if isinstance(dim.dimension, Dimension):
            dim.dimension.dxf.layer = "DIM"

def build_dimensioned_dxf(payload):
    doc = _new_doc_mm()
    msp = doc.modelspace()
    _add_primitives(msp, payload)
    _add_dimensions(msp, payload)
    # タイトル（任意）
    if payload.title:
        txt = msp.add_text(payload.title, dxfattribs={"height": 5, "layer": "TEXT"})
        txt.dxf.insert = (0, -15)  # TEXT の位置指定は dxf.insert で
    return doc

def build_cam_dxf(payload):
    # CAM 向け：寸法は入れず、輪郭・穴だけ。レイヤ分けでCAM側がフィルタ可能
    doc = _new_doc_mm()
    msp = doc.modelspace()
    _add_primitives(msp, payload)
    return doc
