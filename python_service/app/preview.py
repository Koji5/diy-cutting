from typing import Tuple
from html import escape as h

def _bbox_init(): return [float("inf"), float("inf"), float("-inf"), float("-inf")]
def _bbox_upd(b,x,y): b[0]=min(b[0],x); b[1]=min(b[1],y); b[2]=max(b[2],x); b[3]=max(b[3],y)

def _bbox_from_payload(p)->Tuple[float,float,float,float]:
    b=_bbox_init()
    for pl in p.polylines or []:
        for x,y in pl.points: _bbox_upd(b,x,y)
    for c in p.circles or []:
        cx,cy=c.center; r=c.r; _bbox_upd(b,cx-r,cy-r); _bbox_upd(b,cx+r,cy+r)
    # 寸法の基準点も加味
    for d in p.dimensions or []:
        if getattr(d,"p1",None): _bbox_upd(b,d.p1[0],d.p1[1])
        if getattr(d,"p2",None): _bbox_upd(b,d.p2[0],d.p2[1])
        if getattr(d,"base",None): _bbox_upd(b,d.base[0],d.base[1])
    if b[0]==float("inf"): b=[0,0,100,100]
    return tuple(b)

def build_base_svg(payload, vw=900, vh=600, margin=20)->str:
    minx,miny,maxx,maxy=_bbox_from_payload(payload)
    sx=(vw-2*margin)/max(1e-9, (maxx-minx))
    sy=(vh-2*margin)/max(1e-9, (maxy-miny))
    s=min(sx,sy)
    tx=lambda x: margin + (x-minx)*s
    ty=lambda y: vh - (margin + (y-miny)*s)  # SVGは上向きY→反転

    seg=[]
    # 背景/枠
    seg.append(f'<rect x="0" y="0" width="{vw}" height="{vh}" fill="white" stroke="#ddd"/>')
    # タイトル
    if getattr(payload,"title",None):
        seg.append(f'<text x="{margin}" y="{margin+18}" font-family="sans-serif" font-size="18">{h(payload.title)}</text>')

    # 外形やパス（ポリライン）
    for pl in payload.polylines or []:
        pts=' '.join(f'{tx(x):.2f},{ty(y):.2f}' for x,y in pl.points)
        seg.append(f'<polyline points="{pts}" fill="none" stroke="#111" stroke-width="1.6" {"stroke-linejoin=\"round\"" if pl.closed else ""}/>')

    # 円
    for c in payload.circles or []:
        cx,cy=c.center; r=c.r
        seg.append(f'<circle cx="{tx(cx):.2f}" cy="{ty(cy):.2f}" r="{r*s:.2f}" fill="none" stroke="#0a7" stroke-width="1.6"/>')

    # 寸法（簡易）：p1–p2に寸法線/矢印、baseに寸法値
    for d in payload.dimensions or []:
        if d.kind in ("linear","aligned") and getattr(d,"p1",None) and getattr(d,"p2",None):
            x1,y1=d.p1; x2,y2=d.p2
            seg.append(f'<line x1="{tx(x1):.2f}" y1="{ty(y1):.2f}" x2="{tx(x2):.2f}" y2="{ty(y2):.2f}" stroke="#d33" stroke-width="1.4" stroke-dasharray="6 4"/>')
            # 寸法値
            import math
            dist=math.hypot(x2-x1,y2-y1)
            bx,by=(getattr(d,"base", ( (x1+x2)/2, (y1+y2)/2 )))
            seg.append(f'<text x="{tx(bx):.2f}" y="{ty(by):.2f}" text-anchor="middle" font-family="sans-serif" font-size="14" fill="#d33">{dist:.2f} mm</text>')

    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{vw}" height="{vh}" viewBox="0 0 {vw} {vh}">' + ''.join(seg) + '</svg>'
