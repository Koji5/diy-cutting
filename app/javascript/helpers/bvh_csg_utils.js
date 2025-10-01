import { Evaluator, Brush, ADDITION, SUBTRACTION, INTERSECTION } from "three-bvh-csg/index.module";

const sharedEvaluator = new Evaluator();
let _csgSeq = 0;
let _csgBusy = false;                  // 再入ガード（任意）

// 共通処理： meshA を直接書き換える（geometry だけ差し替え）
function csgReplaceGeometry(meshA, meshB, OP, debug) {
  const test = OP === 1 ? "subtraction" : "union"
  if (_csgBusy) { console.warn('CSG busy - skipped'); return; }
  _csgBusy = true;
  const label = `CSG.evaluate#${++_csgSeq}:${test}:${debug}`;

  const evaluator = sharedEvaluator;   // ※毎回 new しない（後述）
  // ここで console.time 開始
  console.time(label);
  try {
    meshA.updateMatrixWorld( true );
    meshB.updateMatrixWorld( true );

    const A = new Brush(meshA.geometry.clone());
    const B = new Brush(meshB.geometry.clone());

    // ワールド変換を Brush に反映（matrixAutoUpdate を止めて直接使う）
    A.matrixWorld.copy(meshA.matrixWorld)
    B.matrixWorld.copy(meshB.matrixWorld)
    A.matrixAutoUpdate = false
    B.matrixAutoUpdate = false

    // 演算
    const out = evaluator.evaluate(A, B, OP);

    // 旧BVHがあるなら破棄（three-mesh-bvh を使っている場合）
    meshA.geometry?.boundsTree?.dispose?.();
    const oldGeo = meshA.geometry;

    // 差し替え
    meshA.geometry = out.geometry;
    // 必要な境界を先に構築（raycast安定化）
    meshA.geometry.computeBoundingBox();
    meshA.geometry.computeBoundingSphere();
    // 法線は必要時のみ（毎回重いので必要な描画直前に）
    // meshA.geometry.computeVertexNormals();

    // BVH再構築（acceleratedRaycast使用時）
    //meshA.geometry.computeBoundsTree?.();

    // out側のmaterialは不要
    out.material?.dispose?.();

    // 旧ジオメトリの破棄は“次フレーム”に遅延（同フレームのraycast競合回避）
    requestAnimationFrame(() => {
      oldGeo?.dispose?.();
      A.geometry?.dispose?.();
      B.geometry?.dispose?.();
    });
  } finally {
    console.timeEnd(label);            // ★ 必ず同じラベルで閉じる
    _csgBusy = false;
  }
}

// A ∪ B（足し算：和）
export function unionMesh(meshA, meshB, debug = "") {
  csgReplaceGeometry(meshA, meshB, ADDITION, debug)
}

// A − B（引き算：差）
export function subtractionMesh(meshA, meshB, debug = "") {
  csgReplaceGeometry(meshA, meshB, SUBTRACTION, debug)
}

// A ∩ B（共通部分）
export function intersectionMesh(meshA, meshB, debug = "") {
  csgReplaceGeometry(meshA, meshB, INTERSECTION, debug)
}
