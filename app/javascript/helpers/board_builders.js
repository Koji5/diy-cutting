import * as THREE from "three";

export function buildBoardGeometry(ctx) {
  const s = new THREE.Shape();
  s.moveTo(0, 0);
  s.lineTo(ctx.length_mm, 0);
  s.lineTo(ctx.length_mm, ctx.width_mm);
  s.lineTo(0, ctx.width_mm);
  s.closePath();
  return new THREE.ExtrudeGeometry(s, {
    depth: -Number(ctx.thickness_mm),
    bevelEnabled: false,   // 側面は直角
  });
}