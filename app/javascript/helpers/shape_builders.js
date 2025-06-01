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
  s.moveTo(-l / 2, 0);
  s.lineTo( l / 2, 0);
  s.lineTo( l / 2, -w);
  s.lineTo(-l / 2, -w);
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

