/********************************************************************
 *  Shape Builders – only the pieces we really need right now
 *    - buildRect({ w, l })
 *    - buildNicheSagitta({ w1, w2, l })
 *******************************************************************/
import * as THREE from "three";

/* -------------------------------------------------------------- */
/*  1) Simple Rectangle                                            */
/* -------------------------------------------------------------- */
export function buildRect({ w, l }) {
  const s = new THREE.Shape();
  s.moveTo(-l / 2, w / 2);
  s.lineTo( l / 2, w / 2);
  s.lineTo( l / 2, -w / 2);
  s.lineTo(-l / 2, -w / 2);
  s.closePath();
  return s;
}

/*───────────────────────────────────────────────────────────────────
  buildNicheSagitta({ w1, w2, l })
    w1  背面の高さ (巾1)
    w2  前面全高   (巾2)  ※ w2 > w1
    l   長さ       (弦長) 例 1000
───────────────────────────────────────────────────────────────────*/
export function buildNicheSagitta({ w1: W1, w2: W2, l: L }) {
  /* ---- 入力チェック ------------------------------------------------ */
  if (!W1 || !L) return buildRect({ w: W1, l: L });      // 必須欠け
  if (!Number.isFinite(W2)) W2 = W1;                     // ★巾2 未入力なら巾1で上書き
  const sag = W2 - W1;                                   // 矢高
  if (sag <= 0)  return buildRect({ w: W1, l: L });      // 張り出しゼロ
  const halfChord = L / 2;

  /* ---- 半径 R (弦長 c=L, 矢高 s=sag) ------------------------------ */
  const R = (sag * sag + halfChord * halfChord) / (2 * sag);

  /* ---- 円弧端角 φ₀ ------------------------------------------------ */
  const phi0 = Math.acos(halfChord / R);                 // 0 < φ₀ < π/2

  /* ---- Shape ----------------------------------------------------- */
  const shape = new THREE.Shape();
  const centerY = - (R - sag);                           // 円心 Y

  /* ① 左背面下 → 左背面上 (長方形左側面) */
  shape.moveTo(-halfChord, -W1);
  shape.lineTo(-halfChord, 0);

  /* ② 円弧 (左端→右端, 時計回り) */
  const SEG = 64;
  for (let i = 0; i <= SEG; i++) {
    const θ = Math.PI - phi0 - i * (Math.PI - 2 * phi0) / SEG; // π−φ₀ → φ₀
    const x =  R * Math.cos(θ);
    const y =  centerY + R * Math.sin(θ);
    shape.lineTo(x, y);
  }

  /* ③ 右背面上 → 右背面下 → 閉じる */
  shape.lineTo( halfChord,  0);
  shape.lineTo( halfChord, -W1);
  shape.closePath();

  return shape;
}

/**
 * 角フィレット付き矩形
 * w : 巾（Y：上0 → 下 -w）
 * l : 長さ（X：左 -l/2 → 右 +l/2）
 * rTL, rTR, rBL, rBR : 各コーナー半径
 */
export function buildCornerFillet({ w, l,
  rTL = 0, rTR = 0, rBL = 0, rBR = 0 })
{
  const s = new THREE.Shape();

  /* ==== 1) TOP EDGE ==== */
  s.moveTo(-l / 2 + rTL, 0);                  // 始点（左上から rTL 分だけ右へ）
  s.lineTo(l / 2 - rTR, 0);                   // 右上手前まで直線

  /* ==== 2) TOP-RIGHT ARC ==== */
  if (rTR > 0) {
    s.absarc(                                    // centerX, centerY
      l / 2 - rTR, -rTR,                         // 右上隅から内側へ (rTR, rTR)
      rTR,           // radius
      Math.PI * 0.5, 0,                         // 90° → 0°（CW）
      true                                       // clockwise
    );
  }

  /* ==== 3) RIGHT EDGE ==== */
  s.lineTo(l / 2, -w + rBR);

  /* ==== 4) BOTTOM-RIGHT ARC ==== */
  if (rBR > 0) {
    s.absarc(
      l / 2 - rBR, -w + rBR,
      rBR,
      0, -Math.PI * 0.5,                        // 0° → -90°（CW）
      true
    );
  }

  /* ==== 5) BOTTOM EDGE ==== */
  s.lineTo(-l / 2 + rBL, -w);

  /* ==== 6) BOTTOM-LEFT ARC ==== */
  if (rBL > 0) {
    s.absarc(
      -l / 2 + rBL, -w + rBL,
      rBL,
      -Math.PI * 0.5, -Math.PI,                 // -90° → -180°（CW）
      true
    );
  }

  /* ==== 7) LEFT EDGE ==== */
  s.lineTo(-l / 2, -rTL);

  /* ==== 8) TOP-LEFT ARC ==== */
  if (rTL > 0) {
    s.absarc(
      -l / 2 + rTL, -rTL,
      rTL,
      Math.PI, Math.PI * 0.5,                   // 180° → 90°（CW）
      true
    );
  }

  s.closePath();
  return s;
}

function _filletCorner(shape, cx,cy,R, θ0,θ1,seg){
  if(R<=0){ shape.lineTo(cx,cy); return; }
  for(let i=0;i<=seg;i++){
    const θ = θ0 + (θ1-θ0)*i/seg;
    shape.lineTo(cx+R*Math.cos(θ), cy+R*Math.sin(θ));
  }
}
function _filletEdge(shape,x,y){ shape.lineTo(x,y); }

/* ─────────── 片側アール（左面）─────────── */
export function buildSideArc1({ w,l, rTL=0, rBL=0 }){
  return buildCornerFillet({ w,l, rTL,rBL });  // 左だけフィレット
}

/********************************************************************
 *   buildSideUArc({ w, l, both })                片側 / 両側 U 字アール
 *      w   : 巾1 [mm]  （半径 = w/2）
 *      l   : 長さ [mm] （全長に半円を含む）
 *      both: true  → SIDE_UARC2  （両側）
 *            false → SIDE_UARC1  （左側のみ）
 *******************************************************************/
export function buildSideUArc({ w, l, both = false }) {
  const r = w / 2;                      // 半径
  const s = new THREE.Shape();

  /* --- カプセル形（両側 U 字）-------------------------------- */
  if (both) {
    const rect = Math.max(l - w, 0);    // 半円を除いた直線部分の長さ
    const hx   = rect / 2;              // 直線両端の ±X

    // 上辺 → 左半円
    s.moveTo( hx,   0);
    s.lineTo(-hx,   0);
    s.absarc(-hx, -r, r,  Math.PI / 2, -Math.PI / 2, false);

    // 下辺 → 右半円
    s.lineTo( hx,  -w);
    s.absarc( hx, -r, r, -Math.PI / 2,  Math.PI / 2, false);
  }

  /* --- 片側 U 字（左側のみ半円）------------------------------ */
  else {
    // 上辺 → 左半円
    s.moveTo( l/2,  0);
    s.lineTo(-l/2 + r, 0);
    s.absarc(-l/2, -r, r,  Math.PI / 2, -Math.PI / 2, false);

    // 下辺 → 右辺
    s.lineTo( l/2, -w);
    s.lineTo( l/2,  0);     // 戻ってクローズ
  }

  s.closePath();
  return s;
}


/* ─────────── 正三角形 ────────── */
export function buildTriEq({ l }){
  const h = l*Math.sin(Math.PI/3);         // 高さ
  const s = new THREE.Shape();
  s.moveTo(-l/2,0);
  s.lineTo( l/2,0);
  s.lineTo( 0,-h);
  s.closePath();
  return s;
}

/**
 * コーナーA型  (L字 + 90° 凸円弧)
 *   w : 巾1［mm］のみ使用。length_mm は無視
 *
 * 端点:
 *   A (-w/2,  +w/2)   ← 左上
 *   B ( +w/2, +w/2)   ← 右上
 *   C ( +w/2, -w/2)   ← 右下
 *   円弧: C → A, 中心 O = (-w/2, -w/2), 半径 w
 */
export function buildCornerTri({ w }) {
  if (!w || w <= 0) return buildRect({ w, l: w });

  const s = new THREE.Shape();

  /* 上辺 → 右辺 */
  s.moveTo(-w / 2,  w / 2);   // A
  s.lineTo( w / 2,  w / 2);   // B
  s.lineTo( w / 2, -w / 2);   // C

  /* C → A を 90°（CCW）で結ぶ凸円弧 */
  s.absarc(
    w / 2, w / 2,          // 中心 O
    w,                        // 半径
    -Math.PI / 2, -Math.PI,         // 0° → 90°
    true                     // CCW なので clockwise=false
  );

  s.closePath();
  return s;
}

/* ─────────── 円／半円─────────── */
export const buildCircle      = ({ d }) => {
  return new THREE.Shape().absarc(0,0, d/2, 0,Math.PI*2,false);
};
export const buildSemiCircle  = ({ d }) => {
  const s=new THREE.Shape();
//  s.absarc(0,0,d/2,0,Math.PI,false);   // 上半分
//  s.lineTo(-d/2,0);
  s.absarc(0, -d/4, d/2, -Math.PI, 0, true);   // 上半分
  s.lineTo(-d/4, -d/4);
  s.closePath();
  return s;
};
