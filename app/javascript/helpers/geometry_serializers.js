import * as THREE        from "three";

// ==== ヘルパ：BufferGeometry を軽量 JSON に整形 ====
export function serializeGeometryForSubmit(geo) {
  const g = geo.index ? geo : geo; // indexedのまま送る（軽量）
  g.computeBoundingBox?.();

  // 数値を軽量化（小数3桁に丸め）
  const q = (v) => Math.round(v * 1000) / 1000;

  // TypedArray → 通常配列化（丸め込み）
  const toArr = (ta) => ta ? Array.from(ta, q) : undefined;

  // attributes
  const pos    = g.getAttribute("position");
  const normal = g.getAttribute("normal");
  const uv     = g.getAttribute("uv");
  const color  = g.getAttribute("color");
  const index  = g.index;

  const bbox = g.boundingBox
    ? {
        min: [q(g.boundingBox.min.x), q(g.boundingBox.min.y), q(g.boundingBox.min.z)],
        max: [q(g.boundingBox.max.x), q(g.boundingBox.max.y), q(g.boundingBox.max.z)]
      }
    : undefined;

  return {
    type: "BufferGeometry(minimal)",
    itemSize: {
      position: pos?.itemSize,
      normal  : normal?.itemSize,
      uv      : uv?.itemSize,
      color   : color?.itemSize
    },
    attributes: {
      position: pos ? toArr(pos.array) : undefined,
      normal  : normal ? toArr(normal.array) : undefined,
      uv      : uv ? toArr(uv.array) : undefined,
      color   : color ? toArr(color.array) : undefined
    },
    index: index ? Array.from(index.array) : undefined, // index は整数なので丸め不要
    groups: g.groups?.length ? g.groups.map(gr => ({ start: gr.start, count: gr.count, materialIndex: gr.materialIndex ?? 0 })) : undefined,
    boundingBox: bbox,
    meta: {
      version: 1,
      vertexCount: pos ? pos.count : 0,
      indexed: Boolean(index)
    }
  };
}

// ===== 復元：軽量 JSON -> BufferGeometry =====
export function inflateGeometryFromJSON(json) {
  const g = new THREE.BufferGeometry();

  const fromArr = (arr, itemSize, ctor = Float32Array) => {
    if (!arr) return null;
    const ta = new ctor(arr);
    const attr = new THREE.BufferAttribute(ta, itemSize);
    return attr;
  };

  const it = json.itemSize || {};
  const attr = json.attributes || {};

  // attributes
  if (attr.position) g.setAttribute("position", fromArr(attr.position, it.position ?? 3, Float32Array));
  if (attr.normal)   g.setAttribute("normal",   fromArr(attr.normal,   it.normal   ?? 3, Float32Array));
  if (attr.uv)       g.setAttribute("uv",       fromArr(attr.uv,       it.uv       ?? 2, Float32Array));
  if (attr.color)    g.setAttribute("color",    fromArr(attr.color,    it.color    ?? 3, Float32Array));

  // index（Uint16/32 は自動選択でもOKだが、配列長で32bitが必要な場合は明示）
  if (json.index) {
    const maxIdx = Math.max(...json.index);
    const IndexCtor = (maxIdx > 65535) ? Uint32Array : Uint16Array;
    g.setIndex(new THREE.BufferAttribute(new IndexCtor(json.index), 1));
  }

  // groups
  if (Array.isArray(json.groups)) {
    json.groups.forEach(gr => g.addGroup(gr.start, gr.count, gr.materialIndex ?? 0));
  }

  // boundingBox
  if (json.boundingBox?.min && json.boundingBox?.max) {
    const { min, max } = json.boundingBox;
    g.boundingBox = new THREE.Box3(
      new THREE.Vector3(min[0], min[1], min[2]),
      new THREE.Vector3(max[0], max[1], max[2])
    );
  } else {
    g.computeBoundingBox?.();
  }

  // 必要なら法線や境界を補う
  if (!g.getAttribute("normal")) g.computeVertexNormals?.();

  return g;
}
