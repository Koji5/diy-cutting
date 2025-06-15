// helpers/modifiers.js
//
// Three.js + three-csg-ts 用ユーティリティ
// --------------------------------------------------------------
import * as THREE from "three";
import { buildEdgeCutters } from "helpers/edge_builders";
import { Evaluator, Brush, SUBTRACTION } from "three-bvh-csg/index.module";

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
  let resultMesh = baseMesh;
  if (cutters.length) {
    cutters.forEach(cutter => {
      try {
        if (!cutter.attributes.normal) {
          cutter.computeVertexNormals();
        }
        const cutterMesh = new THREE.Mesh(
          cutter,
          new THREE.MeshStandardMaterial({ color: 0x6699ff, metalness:0.2, roughness:0.7 })
        );
        resultMesh.updateMatrixWorld( true );
        cutterMesh.updateMatrixWorld( true );
        const resultBrush = new Brush( resultMesh.geometry, resultMesh.material );
        const cutterBrush = new Brush( cutterMesh.geometry, cutterMesh.material );
        resultBrush.matrixWorld.copy( resultMesh.matrixWorld );
        cutterBrush.matrixWorld.copy( cutterMesh.matrixWorld );
        resultBrush.matrixAutoUpdate = cutterBrush.matrixAutoUpdate = false;
        const evaluator = new Evaluator();
        resultMesh = evaluator.evaluate(
          resultBrush,            // A
          cutterBrush,           // B
          SUBTRACTION            // A − B  (= 引き算)
        );
      } catch (err) {
        console.warn(`warn at cutter`);
        resultMesh = baseMesh;
      }
    });
  } else {
    console.warn('cuttersがありません');
  }
  _centerGeometry(resultMesh.geometry);   // エッジ加工後に XYZ 原点合わせ
  return resultMesh;
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
