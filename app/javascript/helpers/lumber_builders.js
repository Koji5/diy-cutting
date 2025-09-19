import * as THREE from "three";

import { unionMesh, subtractionMesh } from "helpers/bvh_csg_utils";
import { lumberBuildCtx } from "helpers/lumber_build_ctx";

// ===== 材質キャッシュ（色や共通質感をまとめる） =====
const materialCache = new Map();
const SHARED_CSG_MAT = new THREE.MeshBasicMaterial({ visible: false });

function mat(key, fallback) {
  if (!materialCache.has(key)) materialCache.set(key, fallback)
  return materialCache.get(key)
}

// ===== 名前生成（未指定は省略） =====
function makeName(...parts) {
  return parts.filter(v => v != null && v !== "").join(":")
}

function getMeshStandardMaterial(color, opacity) {
  return new THREE.MeshStandardMaterial({
          color: color,
          transparent: true,   // ← 必須
          opacity: opacity,       // 0(完全透明)〜1(不透明)
          depthWrite: true,   // 透過重なりのチラつき軽減に有効（必要に応じて）
          metalness: 0,
          roughness: 0.9,
          side: THREE.FrontSide, // 両面にしたいなら DoubleSide。ただし透過はアーティファクトが増えやすい
          flatShading: true
        });
}

export function buildMeshesFromCtx(lumberJSON) {
  if (!lumberJSON) return;
  const ctx = lumberBuildCtx(lumberJSON);
  const lumberShape = new THREE.Shape();
  lumberShape.moveTo(...ctx.moveTo);
  ["bl", "b", "br", "r", "tr", "t", "tl", "l"].forEach(pos=>{

  });

}