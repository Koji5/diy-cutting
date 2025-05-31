import * as THREE from "three";
import { CSG } from "three-csg-ts/CSG"; // importmap key と一致させる
import { RoundedBoxGeometry } from "three/examples/jsm/geometries/RoundedBoxGeometry.js";

/** ------------------------------------------------------------------------
 * buildRoundedRect(ctx)
 * -------------------------------------------------------------------------
 * 角 R 付き直方体の Mesh を返す (CSG 用に THREE.Mesh で包む)
 * ctx = { w, t, l, r }
 */
export function buildRoundedRect(ctx) {
  const geo = new RoundedBoxGeometry(ctx.w, ctx.t, ctx.l, 1, ctx.r);
  const mat = new THREE.MeshPhongMaterial({ color: 0xcccccc });
  return new THREE.Mesh(geo, mat);
}

/** ------------------------------------------------------------------------
 * applyRoundHoles(baseMesh, ctx)
 * -------------------------------------------------------------------------
 * ctx.holes = [ { x, z, dia } ... ]
 *   - 穴は板厚方向 (Y 軸) へ全面貫通
 *   - return: THREE.Mesh (subtract 後の結果)
 */
export function applyRoundHoles(baseMesh, ctx) {
  if (!ctx.holes || ctx.holes.length === 0) return baseMesh;

  const cylGroup = new THREE.Group();
  const h = ctx.t * 1.1; // 少し長めにして完全貫通を保証
  ctx.holes.forEach(({ x, z, dia }) => {
    const geo = new THREE.CylinderGeometry(dia * 0.5, dia * 0.5, h, 32);
    const mat = new THREE.MeshPhongMaterial();
    const m = new THREE.Mesh(geo, mat);
    m.rotation.z = Math.PI / 2; // Y 軸貫通 (Z→Y)
    m.position.set(x, 0, z);
    cylGroup.add(m);
  });

  const result = CSG.subtract(baseMesh, cylGroup);
  result.updateMatrixWorld();
  return result;
}
