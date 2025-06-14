// helpers/modifiers.js
//
// Three.js + three-csg-ts 用ユーティリティ
// --------------------------------------------------------------
import * as THREE from "three";
import { CSG } from "three-csg-ts/CSG";
// import { BufferGeometryUtils } from "three/examples/jsm/utils/BufferGeometryUtils.js";
import * as BufferGeometryUtils from "three/examples/jsm/utils/BufferGeometryUtils.js";
import { buildEdgeCutters } from "helpers/edge_builders";

// --------------------------------------------------------------
// 1. 平面 Shape → 板 (ExtrudeGeometry)
// --------------------------------------------------------------
export function extrudePlate(shape, t) {
  return new THREE.ExtrudeGeometry(shape, {
    depth: t,
    bevelEnabled: false,   // 側面は直角
  });
}

// --------------------------------------------------------------
// 2. エッジ加工 (8 方向)
// --------------------------------------------------------------
export function applyEdges(baseMesh, ctx) {
  if (!baseMesh) return;
  const cutters = buildEdgeCutters(ctx);
  let result;
  if (cutters.length) {
    //const validCutters = cutters.filter(g => g && g.isBufferGeometry);
    //let toolGeo = BufferGeometryUtils.mergeGeometries(validCutters, false);
    //if (!toolGeo) {
    //  console.warn('mergeGeometries failed – attribute mismatch');
    //  return baseMesh;                                // ここで安全に抜ける
    //}
    //toolGeo = toolGeo.toNonIndexed();                      //    （重複頂点を展開）
    //toolGeo.clearGroups();                      // ② マテリアルグループを空に
    result = baseMesh;
    cutters.forEach(cutter => {
      result = CSG.subtract(result, new THREE.Mesh(cutter));
      //const wireMat = new THREE.MeshStandardMaterial({ color: 0xff9966, metalness:0.2, roughness:0.7 });
      //result = new THREE.Mesh(cutter, wireMat);
    });
    //result = new THREE.Mesh(toolGeo);
  } else {
    console.warn('cuttersがありません');
    result = baseMesh;
  }
  //_centerGeometry(result.geometry);   // エッジ加工後に XYZ 原点合わせ
  return result;
}

// --------------------------------------------------------------
// 3. 内部 util
// --------------------------------------------------------------
function _centerGeometry(geo) {
  geo.computeBoundingBox();
  const box = geo.boundingBox;
  const offX = (box.max.x + box.min.x) / 2;
  const offY = (box.max.y + box.min.y) / 2;
  const offZ = (box.max.z + box.min.z) / 2;
  geo.translate(-offX, -offY, -offZ);
}
