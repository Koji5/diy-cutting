import * as THREE from "three";
import { buildEgePath } from "helpers/shape_builders";

export function buildEdgeCutters(ctx) {
  const cutters = [];
  const KEYS  = ["tl", "t", "tr", "l", "r", "bl", "b", "br"];
  KEYS.forEach(key => {
    const info = ctx.edges?.[key] ?? { code: "NONE" };
    const { code, opts = {} } = info;
    if (code === "NONE") return
    const edgePath = buildEgePath(ctx, key);
    const profile = edgeProfile(code, ctx);
    const cutterGeo = new THREE.ExtrudeGeometry(profile, {
      extrudePath  : edgePath,
      steps        : Math.ceil(edgePath.getLength()/2),
      bevelEnabled : false
    });
    cutters.push(cutterGeo);
  });
  return cutters;
}








  //const { L, W1: W, corners: C, T } = ctx;
  
  //KEYS.forEach(key => {
  //  const info = ctx.edges?.[key] ?? { code: "NONE" };
  //  const { code, opts = {} } = info;
  //  switch (code) {
  //    case "CHAMF_BTH":
  //      const tX = C.tl.code === "CHAMFER" || C.tl.code === "BEVEL" ? C.tl.dx : C.tl.r;
  //      const startT = new THREE.Vector3(tX, W, 0);
  //      const trX = C.tr.code === "CHAMFER" || C.tr.code === "BEVEL" ? C.tr.dx : C.tr.r;
  //      const endT = new THREE.Vector3(L - trX, W, 0);
  //      const path = new THREE.CurvePath();
  //      path.add( new THREE.LineCurve3( startT, endT ));
  //      const rY = C.tr.code === "CHAMFER" || C.tr.code === "BEVEL" ? W - C.tr.dy : W - C.tr.r;
  //      const startR = new THREE.Vector3(L, rY, 0);
  //      const brY = C.br.code === "CHAMFER" || C.br.code === "BEVEL" ? C.br.dy : C.br.r;
  //      const endR = new THREE.Vector3(L, brY, 0);
  //      path.add( new THREE.LineCurve3( startR, endR ));

  //      const profile = new THREE.Shape()
  //      .moveTo(0, 1).lineTo(0, 0).lineTo(-T /2 , -25).lineTo(-T, 0).lineTo(-T, 1).closePath();
  //      const thickness = T; 

  //      cutters.push(cutterGeo);
  //      console.log("cutterGeo = ", cutterGeo);
  //      break;
  //  }
  //});
  //const KEYS  = ["tl", "t", "tr", "l", "r", "bl", "b", "br"];
  //KEYS.forEach(key => {
  //  const info = ctx.edges?.[key] ?? { code: "NONE" };
  //  const { code, opts = {} } = info;
  //  switch (code) {
  //    case "CHAMF_BTH":
  //    case "CHM5MM":
  //    case "CHM10MM":
  //    case "R5ROUND":
  //    case "R10ROUND":
  //    case "BULLNOSE":
  //      cutters.push(...buildCutter(ctx, key, code, "bottom"));
  //    case "COVE":
  //    case "OGEE":
  //      cutters.push(...buildCutter(ctx, key, code, "top"));
  //      break;
  //  }
  //});
  //return cutters;
//}

function buildCutter(ctx, key, code, position) {
  /* -------- 1. プロファイル: Y=1 mm の極細三角形 (ローカルXZ断面) -------- */
  const profShape = position === "top" ? edgeProfileTop(code, ctx) : edgeProfileBottom(code, ctx);
  if (!profShape) return [];
  // Extrude:   depth=1 → ローカル Y=1 mm のストリップ
  const protoGeo = new THREE.ExtrudeGeometry(profShape, {
    depth: 1,
    steps: 1,
    bevelEnabled: false,
  })
    .rotateX(Math.PI / 2)
    .translate(0, 0.5, 0);
  /* -------- 2. 外周 Path （直線＋円弧＝開いたまま） -------- */
  const path = buildEgePath(ctx, key);
  /* -------- 3. 曲線ごとに「適切な分割点」を生成 -------- */
  const STEP = 5;
  function splitCurve(curve) {
    return curve.isLineCurve
      ? curve.getPoints(1)                       // 始点・終点のみ
      : curve.getPoints(Math.ceil(curve.getLength() / STEP));
  }
  /* -------- 4. 時計／反時計を判定 → 右側を「内側」に統一 -------- */
  //function signedArea(arr) {
  //  let a = 0;
  //  for (let i = 0; i < arr.length - 1; i++) {
  //    a += arr[i].x * arr[i + 1].y - arr[i + 1].x * arr[i].y;
  //  }
  //  return a / 2;
  //}
  /* -------- 5. 工具を複製して cutters 配列へ -------- */
  const cutters = [];

  path.curves.forEach((curve) => {
    const pts = splitCurve(curve);
    //const orient = signedArea(pts) < 0 ? -1 : +1; 
    for (let i = 0; i < pts.length - 1; i++) {
      const p0 = pts[i];
      const p1 = pts[i + 1];

      // 辺ベクトル v
      const v = new THREE.Vector2().subVectors(p1, p0);
      const len = v.length();
      if (!len) continue;            // ゼロ長をスキップ

      const ang = Math.atan2(v.y, v.x);

      // --- プロトタイプをクローンして回転・伸長・平行移動 ---
      const EPS = 0.05;
      const g = protoGeo.clone()
        .translate( -EPS, 0, 0 )
        .scale(1, len, 1)
        .rotateZ(ang - Math.PI / 2)
        .translate(
          p0.x + (p1.x - p0.x) / 2,
          p0.y + (p1.y - p0.y) / 2,
          0
        );

      cutters.push(g);
    }
  });
  return cutters;
}

/* ---------- 1. 断面プロファイル ---------- */
function edgeProfile(code, ctx) {
  const T = ctx.T;
  const s = new THREE.Shape();
  s.moveTo(0, 1);
  switch (code) {
    case "CHAMF_BTH": { // 上下糸面
      s.lineTo(0, -1).lineTo(-1, 0).lineTo(-T + 1, 0).lineTo(-T, -1);
      break;
    }
    case "BULLNOSE": { // ボーズ面
      s.lineTo(0, -T / 2);
      s.absarc(-T / 2, -T / 2, T / 2, 0, Math.PI, false);
      break;
    }
    case "CHM5MM": { // 上下5mm面
      s.lineTo(0, -5).lineTo(-5, 0).lineTo(-T + 5, 0).lineTo(-T, -5);
      break;
    }
    case "CHM10MM": { // 上下10mm面
      s.lineTo(0, -10).lineTo(-10, 0).lineTo(-T + 10, 0).lineTo(-T, -10);
      break;
    }
    case "R5ROUND": { // 上下5R面
      s.lineTo(0, -5);
      s.absarc(-5, -5, 5, 0, Math.PI / 2, false);
      s.lineTo(-T + 5, 0);
      s.absarc(-T + 5, -5, 5, Math.PI / 2, Math.PI, false);
      break;
    }
    case "R10ROUND": { // 上下10R面
      s.lineTo(0, -10);
      s.absarc(-10, -10, 10, 0, Math.PI / 2, false);
      s.lineTo(-T + 10, 0);
      s.absarc(-T + 10, -10, 10, Math.PI / 2, Math.PI, false);
      break;
    }
    case "COVE": { // ギンナン面
      s.lineTo(0, -9).lineTo(-3, -9);
      s.absarc(-9, -9, 6, 0, Math.PI / 2, false);
      break;
    }
    case "OGEE": { // 船底面
      s.lineTo(0, -T).lineTo(-T + 10, -5);
      s.absarc(-T + 5, -5, 5, Math.PI / 4, Math.PI, false);
      break;
    }
  }
  s.lineTo(-T, 1).closePath();
  return s;
}



function edgeProfileTop(code, ctx) {
  const T = ctx.T;
  const s = new THREE.Shape();
  switch (code) {
    case "CHAMF_BTH": {
      s.moveTo(0, T - 1);
      s.lineTo(1, T);
      s.lineTo(0, T);
      s.closePath();
      break;
    }
    case "BULLNOSE": {
      s.moveTo(0, 0);
      s.lineTo(T / 2, 0);
      s.absarc(T / 2, T / 2, T / 2, -Math.PI / 2, Math.PI, true);
      s.closePath();
      break;
    }
    // … R5ROUND / COVE / OGEE など
    default:
      return null;
  }
  return s;
}
function edgeProfileBottom(code, ctx) {
  const T = ctx.T;
  const s = new THREE.Shape();
  switch (code) {
    case "CHAMF_BTH": {
      s.moveTo(0, 0);
      s.lineTo(0, 1);
      s.lineTo(1, 0);
      s.closePath();
      break;
    }
    case "BULLNOSE": {
      s.moveTo(0, T);
      s.lineTo(T / 2, T);
      s.absarc(T / 2, T / 2, T / 2, Math.PI / 2, Math.PI, false);
      s.closePath();
      break;
    }
  }
  return s;
}
/* ---------- 2. 外周パス ---------- */
export function buildEdgePath(ctx, key) {
  // ctx.outerShape などから該当辺を抽出して CurvePath を返す
  // 例：矩形板なら LineCurve3 1 本
  const path = new THREE.CurvePath();
  switch (ctx.shapeCode) {
    case "TRI_EQ":  return buildEquilateralEdgePath(ctx, key, path);
    case "NICHE":   return buildNicheEdgePath(ctx, key, path);
    default:        return buildRectEdgePath(ctx, key, path);   // "その他" は矩形 + 任意コーナー
  }
}

/**
 * 2D 円弧 → 3D CurvePath 変換ヘルパ
 * cx        円弧中心 X
 * cy        円弧中心 Y   ※ここでは Z 軸にマッピング
 * r         半径
 * start     開始角 (rad)
 * end       終了角 (rad)
 * cw       時計回りフラグ
 * segs=32   分割数
 * returns Vector3 曲線（CatmullRomCurve3）
 */
function arcCurve3(
  cx, cy, r, start, end, cw, segs = 32
) {
  // 1. まず 2D 円弧 (Vector2) を作る
  const arc2 = new THREE.ArcCurve(cx, cy, r, start, end, cw);

  // 2. 点列を取得 → Vector3 に昇格（y=0、z=2D の y を転写）
  const pts3 = arc2.getPoints(segs).map(p =>
    new THREE.Vector3(p.x, 0, p.y)
  );

  // 3. 連続曲線にして返す
  return new THREE.CatmullRomCurve3(pts3, false); // closed=false
}

function buildRectEdgePath(ctx, key, path) {
  const { L, W1: W, corners: C } = ctx;
  const tlY = C.tl.code === "CHAMFER" || C.tl.code === "BEVEL" ? C.tl.dy : C.tl.r;
  const blX = C.bl.code === "CHAMFER" || C.bl.code === "BEVEL" ? C.bl.dx : C.bl.r;
  const trX = C.tr.code === "CHAMFER" || C.tr.code === "BEVEL" ? C.tr.dx : C.tr.r;
  const brY = C.br.code === "CHAMFER" || C.br.code === "BEVEL" ? C.br.dy : C.br.r;
  switch (key) {
    case "bl": {
      switch (C.bl.code) {
        case "ROUND_R":
        case "NONE":
          path.add(arcCurve3(C.bl.r, C.bl.r, C.bl.r, -Math.PI / 2, Math.PI, true));
          break;
        case "INROUND":
          path.add(arcCurve3(0, 0, C.bl.r, 0, Math.PI / 2, false));
          break;
        case "CHAMFER": {
          const L1 = new THREE.Vector3(blX, 0, 0);
          const L2 = new THREE.Vector3(C.bl.dx, 0, C.bl.dy);
          const L3 = new THREE.Vector3(0, 0, C.bl.dy);
          path.add(new THREE.LineCurve3(L1, L2));
          path.add(new THREE.LineCurve3(L2, L3));
          break;
        }
        case "BEVEL": {
          const L1 = new THREE.Vector3(blX, 0, 0);
          const L2 = new THREE.Vector3(0, 0, C.bl.dy);
          path.add(new THREE.LineCurve3(L1, L2));
          break;
        }
      }
      break;
    }
    case "l": {
      let L1;
      const L2 = new THREE.Vector3(0, 0, W - tlY);
      switch (C.bl.code) {
        case "ROUND_R":
        case "NONE":
        case "INROUND":
          L1 = new THREE.Vector3(0, 0, C.bl.r);
          break;
        case "CHAMFER":
        case "BEVEL":
          L1 = new THREE.Vector3(0, 0, C.bl.dy);
          break;
      }
      path.add(new THREE.LineCurve3(L1, L2));
      break;
    }
    case "tl": {
      switch (C.tl.code) {
        case "ROUND_R":
        case "NONE":
          path.add(arcCurve3(C.tl.r, W - C.tl.r, C.tl.r, Math.PI, Math.PI / 2, true));
          break;
        case "INROUND":
          path.add(arcCurve3(0, W, C.tl.r, -Math.PI / 2, 0, false));
          break;
        case "CHAMFER": {
          const L1 = new THREE.Vector3(0, 0, W - tlY);
          const L2 = new THREE.Vector3(C.tl.dx, 0, W - C.tl.dy);
          const L3 = new THREE.Vector3(C.tl.dx, 0, W);
          path.add(new THREE.LineCurve3(L1, L2));
          path.add(new THREE.LineCurve3(L2, L3));
          break;
        }
        case "BEVEL": {
          const L1 = new THREE.Vector3(0, 0, W - tlY);
          const L2 = new THREE.Vector3(C.tl.dx, 0, W);
          path.add(new THREE.LineCurve3(L1, L2));
          break;
        }
      }
      break;
    }
    case "t": {
      let L1;
      const L2 = new THREE.Vector3(L - trX, 0, W);
      switch (C.tl.code) {
        case "ROUND_R":
        case "NONE":
        case "INROUND":
          L1 = new THREE.Vector3(C.tl.r, 0, W);
          break;
        case "CHAMFER":
        case "BEVEL":
          L1 = new THREE.Vector3(C.tl.dx, 0, W);
          break;
      }
      path.add(new THREE.LineCurve3(L1, L2));
      break;
    }
    case "tr": {
      switch (C.tr.code) {
        case "ROUND_R":
        case "NONE":
          path.add(arcCurve3(L - C.tr.r, W - C.tr.r, C.tr.r, Math.PI / 2, 0, true));
          break;
        case "INROUND":
          path.add(arcCurve3(L, W, C.tr.r, Math.PI, -Math.PI / 2, false));
          break;
        case "CHAMFER": {
          const L1 = new THREE.Vector3(C.tl.r, 0, W);
          const L2 = new THREE.Vector3(L - C.tr.dx, 0, W - C.tr.dy);
          const L3 = new THREE.Vector3(L, 0, W - C.tr.dy);
          path.add(new THREE.LineCurve3(L1, L2));
          path.add(new THREE.LineCurve3(L2, L3));
          break;
        }
        case "BEVEL":
          const L1 = new THREE.Vector3(C.tl.dx, 0, W);
          const L2 = new THREE.Vector3(L, 0, W - C.tr.dy);
          path.add(new THREE.LineCurve3(L1, L2));
          break;
      }
      break;
    }
    case "r": {
      let L1;
      const L2 = new THREE.Vector3(L, 0, brY);
      switch (C.tr.code) {
        case "ROUND_R":
        case "NONE":
        case "INROUND":
          L1 = new THREE.Vector3(L, 0, W - C.tr.r);
          break;
        case "CHAMFER":
        case "BEVEL":
          L1 = new THREE.Vector3(L, 0, W - C.tr.dy);
          break;
      }
      path.add(new THREE.LineCurve3(L1, L2));
      break;
    }
    case "br": {
      switch (C.br.code) {
        case "ROUND_R":
        case "NONE":
          path.add(arcCurve3(L - C.br.r, C.br.r, C.br.r, 0, -Math.PI / 2, true));
          break;
        case "INROUND":
          path.add(arcCurve3(L, 0, C.br.r, Math.PI / 2, Math.PI, false));
          break;
        case "CHAMFER": {
          const L1 = new THREE.Vector3(L, 0, brY);
          const L2 = new THREE.Vector3(L - C.br.dx, 0, C.br.dy);
          const L3 = new THREE.Vector3(L - C.br.dx, 0, 0);
          path.add(new THREE.LineCurve3(L1, L2));
          path.add(new THREE.LineCurve3(L2, L3));
          break;
        }
        case "BEVEL": {
          const L1 = new THREE.Vector3(L, 0, brY);
          const L2 = new THREE.Vector3(L - C.br.dx, 0, 0);
          path.add(new THREE.LineCurve3(L1, L2));
          break;
        }
      }
      break;
    }
    case "b": {
      let L1;
      const L2 = new THREE.Vector3(blX, 0, 0);
      switch (C.br.code) {
        case "ROUND_R":
        case "NONE":
        case "INROUND":
          L1 = new THREE.Vector3(L - C.br.r, 0, 0);
          break;
        case "CHAMFER":
        case "BEVEL":
          L1 = new THREE.Vector3(L - C.br.dx, 0, 0);
          break;
      }
      path.add(new THREE.LineCurve3(L1, L2));
      break;
    }
  }
  return path;
}