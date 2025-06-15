import * as THREE from "three";
import { buildEgePath } from "helpers/shape_builders";

export function buildEdgeCutters(ctx) {
  const cutters = [];
  const KEYS  = ["bl", "l", "tl", "t", "tr", "r", "br", "b"];
  KEYS.forEach(key => {
    const info = ctx.edges?.[key] ?? { code: "NONE" };
    const { code, opts = {} } = info;
    if (code === "NONE") return;
    const edgePath = buildEgePath(ctx, key);
    if (edgePath.getLength() === 0) return;
    const profile = edgeProfile(code, ctx);
    function stepsForCurve(c) {
      if (c.isLineCurve3)          return 1;                 // 直線は 1
      const len  = c.getLength();                            // mm
      const unit = c.isCubicBezierCurve3 ? 2 : 3;            // ベジエ 2 mm, それ以外 3 mm
      return Math.max(1, Math.ceil(len / unit));
    }
    const steps = edgePath.curves.reduce(
      (sum, c) => sum + stepsForCurve(c), 0
    );
    const cutterGeo = new THREE.ExtrudeGeometry(profile, {
      extrudePath  : edgePath,
      steps        : steps,
      bevelEnabled : false
    });
    cutters.push(cutterGeo);
  });
  return cutters;
}


/* ---------- 1. 断面プロファイル ---------- */
function moveToStart(s, y) {
  s.moveTo(1, 1).lineTo(1, y).lineTo(0, y);
}
function moveToEnd(s, y, T) {
  s.lineTo(-T - 1, y).lineTo(-T - 1, 1).closePath();
}
function edgeProfile(code, ctx) {
  const T = ctx.T;
  const s = new THREE.Shape();
  switch (code) {
    case "CHAMF_BTH": { // 上下糸面
      moveToStart(s, -1);
      s.lineTo(-1, 0).lineTo(-T + 1, 0).lineTo(-T, -1);
      moveToEnd(s, -1, T);
      break;
    }
    case "BULLNOSE": { // ボーズ面
      moveToStart(s, -T / 2);
      s.absarc(-T / 2, -T / 2, T / 2, 0, Math.PI, false);
      moveToEnd(s, -T / 2, T);
      break;
    }
    case "CHM5MM": { // 上下5mm面
      moveToStart(s, -5);
      s.lineTo(-5, 0).lineTo(-T + 5, 0).lineTo(-T, -5);
      moveToEnd(s, -5, T);
      break;
    }
    case "CHM10MM": { // 上下10mm面
      moveToStart(s, -10);
      s.lineTo(-10, 0).lineTo(-T + 10, 0).lineTo(-T, -10);
      moveToEnd(s, -10, T);
      break;
    }
    case "R5ROUND": { // 上下5R面
      moveToStart(s, -5);
      s.absarc(-5, -5, 5, 0, Math.PI / 2, false);
      s.lineTo(-T + 5, 0);
      s.absarc(-T + 5, -5, 5, Math.PI / 2, Math.PI, false);
      moveToEnd(s, -5, T);
      break;
    }
    case "R10ROUND": { // 上下10R面
      moveToStart(s, -10);
      s.absarc(-10, -10, 10, 0, Math.PI / 2, false);
      s.lineTo(-T + 10, 0);
      s.absarc(-T + 10, -10, 10, Math.PI / 2, Math.PI, false);
      moveToEnd(s, -10, T);
      break;
    }
    case "COVE": { // ギンナン面
      moveToStart(s, 0);
      s.lineTo(-T + 9, 0).lineTo(-T + 9, -3);
      s.absarc(-T + 9, -9, 6, Math.PI / 2, Math.PI, false);
      moveToEnd(s, -9, T);
      break;
    }
    case "OGEE": { // 船底面
      moveToStart(s, -T + 10 / Math.SQRT2);
      s.lineTo(-T + 5 + 5 / Math.SQRT2, -5 + 5 / Math.SQRT2);
      s.absarc(-T + 5, -5, 5, Math.PI / 4, Math.PI, false);
      moveToEnd(s, -5, T);
      break;
    }
  }
  return s;
}
