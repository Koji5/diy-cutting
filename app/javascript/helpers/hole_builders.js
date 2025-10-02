import * as THREE from "three";
import * as BufferGeometryUtils from "three/examples/jsm/utils/BufferGeometryUtils.js";
import { unionMesh } from "helpers/bvh_csg_utils";


const SHARED_CSG_MAT = new THREE.MeshBasicMaterial({ visible: false });

export function createHoleMesh(hole, T){
  const q = new THREE.Quaternion().setFromEuler(new THREE.Euler(...hole.rad));
  const t = new THREE.Vector3(...hole.trans);
  const s = new THREE.Vector3(1, 1, 1);
  const m = new THREE.Matrix4().compose(t, q, s);
  const geos = buildHoleGeometry(hole.spec_code, hole.depth, hole.countersink, m);
  return geos;
}

function buildHoleGeometry(spec_code, depth, countersink, m) {
  let r = 0, R = 0, d = 0, geoB = null;
  const mg = 0.03;
  switch(spec_code){
    case "M3": r = 3; R = 6; d = 1.5; break;
    case "M4": r = 4; R = 8; d = 2; break;
    case "M5": r = 5; R = 10; d = 2.5; break;
    case "M6": r = 6; R = 12; d = 3; break;
    case "M8": r = 8; R = 16; d = 4; break;
    case "M10": r = 10; R = 20; d = 5; break;
    case "DOWEL6": r = 6; break;
    case "DOWEL8": r = 8; break;
    case "DOWEL10": r = 10; break;
    default:
  }
  if (!countersink) d = 0;
  const shape = new THREE.Shape();
  shape.absarc(0, 0, r, 0, Math.PI * 2, false);
  const geoA = new THREE.ExtrudeGeometry(shape, { depth: depth - d + mg, bevelEnabled: false });
  geoA.translate(0, 0, -(depth + mg)); // 上面Z=0（Z ∈ [-T,0]）
  if (!geoA.attributes.normal) {
    geoA.computeVertexNormals();
  }
  geoA.applyMatrix4(m);
  // 皿部分
  if (countersink && R !== 0) {
    const hole = new THREE.Shape();
    hole.absarc(0, 0, R, 0, Math.PI * 2, false);
    geoB = new THREE.ExtrudeGeometry(hole, { depth: d + mg, bevelEnabled: false });
    geoB.translate(0, 0, -d + mg); // 上面Z=0（Z ∈ [-T,0]）
    if (!geoB.attributes.normal) {
      geoB.computeVertexNormals();
    }
    geoB.applyMatrix4(m);
  }
  return [geoA, geoB];
}