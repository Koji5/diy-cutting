import os, logging
import ezdxf
from ezdxf.entities import Dimension
from ezdxf.math import Vec2

log = logging.getLogger("dxf")

def _bbox_from_payload(payload):
    xs, ys = [], []
    for pl in payload.polylines:
        xs += [p[0] for p in pl.points]
        ys += [p[1] for p in pl.points]
    for c in payload.circles:
        xs += [c.center[0] - c.r, c.center[0] + c.r]
        ys += [c.center[1] - c.r, c.center[1] + c.r]
    if not xs:
        return 0.0, 0.0, 0.0, 0.0
    return min(xs), min(ys), max(xs), max(ys)

def _signed_offset_from_base(p1, p2, base, default=10.0):
    """p1→p2 の線に対し、base が法線方向にどれだけ離れているか（mm, 符号付）。"""
    if base is None:
        return float(default)
    a, b, c = Vec2(p1), Vec2(p2), Vec2(base)
    v = b - a
    if v.magnitude == 0:
        return float(default)
    n = v.rotate_deg(90).normalize()  # 左法線
    return float((c - a).dot(n))

def _infer_orthogonal_angle(p1, p2):
    """linear寸法でangle未指定なら水平(0)か垂直(90)に丸める"""
    v = Vec2(p2) - Vec2(p1)
    return 0.0 if abs(v.x) >= abs(v.y) else 90.0

def _new_doc_mm():
    doc = ezdxf.new("R2010", setup=True)
    doc.units = ezdxf.units.MM

    # ★ TTF/OTF を優先して探す（.ttc は最後に回す）
    candidates = [
        "/usr/share/fonts/opentype/ipafont-gothic/ipag.ttf",        # IPA Gothic (OTF/TTF)
        "/usr/share/fonts/truetype/ipafont-gothic/ipag.ttf",
        "/usr/share/fonts/opentype/ipafont-mincho/ipam.ttf",
        "/usr/share/fonts/truetype/ipafont-mincho/ipam.ttf",
        "/usr/share/fonts/truetype/noto/NotoSansCJKjp-Regular.otf", # OTFがあれば
        "/usr/share/fonts/opentype/noto/NotoSansCJKjp-Regular.otf",
        "/usr/share/fonts/truetype/noto/NotoSansCJKjp-Regular.ttf",
        # 最後の手段として .ttc
        "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
        "/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc",
        "/usr/share/fonts/opentype/noto-cjk/NotoSansCJK-Regular.ttc",
    ]
    cjk_path = next((p for p in candidates if os.path.exists(p)), None)
    log.info(f"[fonts] CJK font chosen: {cjk_path or 'NONE'}")
    print(f"[fonts] _new_doc_mm called", flush=True)
    print(f"[fonts] CJK font chosen: {cjk_path or 'NONE'}", flush=True)

    if cjk_path:
        font_name = os.path.basename(cjk_path) 
        # TEXT STYLE を作成し、DIM の文字スタイルにも適用
        if "CJK" not in doc.styles:
            doc.styles.add("CJK", font=font_name)  # ← dxfattribs ではなく font= で！
        ds = doc.dimstyles.get("EZDXF")
        if ds:
            ds.dxf.dimtxsty = "CJK"  # 寸法値の文字スタイル

    # レイヤ定義
    for name, color in [("OUTER",7),("INNER",8),("POCKET",3),("DRILL",1),("TEXT",7),("DIM",2)]:
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
            # angle未指定なら水平/垂直を自動判定
            angle = getattr(d, "angle", None)
            if angle is None:
                angle = _infer_orthogonal_angle(d.p1, d.p2)

            dim = msp.add_linear_dim(
                base=d.base, p1=d.p1, p2=d.p2, angle=float(angle),
                override=d.override
            )
            dim.render()

        else:  # aligned
            # distance未指定なら base から自動算出
            dist = getattr(d, "distance", None)
            if dist is None:
                dist = _signed_offset_from_base(d.p1, d.p2, getattr(d, "base", None))

            dim = msp.add_aligned_dim(
                p1=d.p1, p2=d.p2, distance=float(dist), override=d.override
            )
            # 念のため
            try:
                dim.render()
            except Exception:
                pass

        # レイヤを DIM に寄せる（任意）
        if isinstance(dim.dimension, Dimension):
            dim.dimension.dxf.layer = "DIM"

def build_dimensioned_dxf(payload):
    doc = _new_doc_mm()
    msp = doc.modelspace()
    _add_primitives(msp, payload)
    _add_dimensions(msp, payload)
    # タイトル（任意）
    if payload.title:
        minx, miny, maxx, maxy = _bbox_from_payload(payload)
        margin = 8.0  # 図の上に 8mm 余白
        cx = (minx + maxx) / 2.0
        y  = maxy + margin
        style = "CJK" if "CJK" in doc.styles else "Standard"
        txt = msp.add_text(payload.title, dxfattribs={"height": 5, "layer": "TEXT", "style": style})
        # 上中央に合わせたいとき：水平=Center(1), 垂直=Top(3) + align_point 指定
        txt.dxf.halign = 1  # center
        txt.dxf.valign = 3  # top
        txt.dxf.align_point = (cx, y)
        # ただの左上起点で良ければこれだけでもOK：
        # txt.dxf.insert = (minx, maxy + margin)
    return doc

def build_cam_dxf(payload):
    # CAM 向け：寸法は入れず、輪郭・穴だけ。レイヤ分けでCAM側がフィルタ可能
    doc = _new_doc_mm()
    msp = doc.modelspace()
    _add_primitives(msp, payload)
    return doc
