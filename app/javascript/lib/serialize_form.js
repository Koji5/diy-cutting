// 使い方
// Railsフォーム（name は part[board_part_attributes][...]) を
// → snake_case キー & *_attributes 畳み込み で得る
//  const data = formToJSON(document.querySelector("form"), {
//    coerceTypes: true,
//    emptyToNull: true,
//    keyCase: "snake",       // or "camel" / null
//    foldAttributes: true,
//    preferBase: true        // base と *_attributes が両方あるなら base を優先
//  });

// 例: data.part.board_part.corner_json.tl.proc にアクセスできる
export function formToJSON(form, {
  coerceTypes = true,          // number/true/false を型変換
  includeDisabled = false,     // 無効要素も含めるか
  emptyToNull = true,          // "" を null にするか
  keyCase = "snake",           // "snake" | "camel" | null  … 変換しないなら null
  foldAttributes = true,       // *_attributes をベース名に畳み込む
  preferBase = true,           // base と *_attributes 両方ある時どちらを優先するか
} = {}) {
  const out = {};
  const els = Array.from(form.elements).filter(el => {
    if (!el.name) return false;
    if (el.disabled && !includeDisabled) return false;
    return !["submit","button","file","image","reset"].includes(el.type);
  });

  for (const el of els) {
    let val;
    if (el.type === "checkbox") {
      if (!el.checked) continue;
      val = (el.value === "on") ? true : el.value;
    } else if (el.type === "radio") {
      if (!el.checked) continue;
      val = el.value;
    } else if (el.tagName === "SELECT" && el.multiple) {
      val = Array.from(el.selectedOptions).map(o => o.value);
    } else {
      val = el.value;
    }

    if (emptyToNull && val === "") val = null;
    if (coerceTypes) val = coerceByType(val, el);

    setDeep(out, parseName(el.name), val);
  }

  // --- ここから後処理（オプション） ---
  let data = out;

  // ① キーのケース変換
  if (keyCase === "snake") {
    data = deepTransformKeys(data, toSnakeCase);
  } else if (keyCase === "camel") {
    data = deepTransformKeys(data, toCamelCase);
  }

  // ② *_attributes の畳み込み（snake/camel 両対応）
  if (foldAttributes) {
    data = foldAttributesKeys(data, { preferBase });
  }

  return data;
}

function coerceByType(val, el) {
  if (val == null) return val;
  if (Array.isArray(val)) return val.map(v => coerceByType(v, el));
  const t = (el.getAttribute("type") || "").toLowerCase();
  if (t === "number" || t === "range") {
    const n = Number(val); return Number.isFinite(n) ? n : null;
  }
  if (val === "true") return true;
  if (val === "false") return false;
  return val;
}

// "part[board_part_attributes][corner_json][tl][dx]" → ["part","board_part_attributes","corner_json","tl","dx"]
function parseName(name) {
  return name.match(/^[^\[]+|\[(.*?)\]/g).map(s => s[0] === "[" ? s.slice(1, -1) : s);
}

function setDeep(obj, path, value) {
  let cur = obj;
  for (let i = 0; i < path.length; i++) {
    const key = path[i];
    const last = i === path.length - 1;
    const nextIsArray = !last && (path[i+1] === "" || /^\d+$/.test(path[i+1]));
    const keyIsArrayPush = key === "";

    if (keyIsArrayPush) {
      if (!Array.isArray(cur)) throw new Error("array push outside array context");
      if (last) { cur.push(value); return; }
      const container = nextIsArray ? [] : {};
      cur.push(container);
      cur = container;
      continue;
    }

    if (last) {
      if (cur[key] !== undefined) {
        if (!Array.isArray(cur[key])) cur[key] = [cur[key]];
        cur[key].push(value);
      } else {
        cur[key] = value;
      }
    } else {
      if (cur[key] === undefined) cur[key] = nextIsArray ? [] : {};
      cur = cur[key];
    }
  }
}

/* ========== 追加: キー変換 & _attributes 畳み込み ========== */

function deepTransformKeys(obj, keyFn) {
  if (Array.isArray(obj)) return obj.map(v => deepTransformKeys(v, keyFn));
  if (obj && typeof obj === "object") {
    const out = {};
    for (const [k, v] of Object.entries(obj)) out[keyFn(k)] = deepTransformKeys(v, keyFn);
    return out;
  }
  return obj;
}

function toSnakeCase(str) {
  // 例: shapeTypeCode → shape_type_code / width → width
  return str
    .replace(/([a-z0-9])([A-Z])/g, "$1_$2")
    .replace(/__/g, "_")
    .toLowerCase();
}

function toCamelCase(str) {
  // 例: shape_type_code → shapeTypeCode / width → width
  return str.replace(/_+([a-zA-Z0-9])/g, (_, c) => c.toUpperCase());
}

function foldAttributesKeys(obj, { preferBase = true } = {}) {
  if (Array.isArray(obj)) return obj.map(v => foldAttributesKeys(v, { preferBase }));
  if (!obj || typeof obj !== "object") return obj;

  const out = {};
  for (const [key, val] of Object.entries(obj)) {
    const v = foldAttributesKeys(val, { preferBase });

    // snake: *_attributes / camel: *Attributes の両対応
    let isAttr = false, base = null;
    if (key.endsWith("_attributes")) {
      isAttr = true; base = key.slice(0, -"_attributes".length);
    } else if (key.endsWith("Attributes")) {
      isAttr = true; base = key.slice(0, -"Attributes".length);
    }

    if (isAttr) {
      if (preferBase) {
        // 既に base があるならそちら優先
        if (out[base] === undefined) out[base] = v;
      } else {
        out[base] = v; // attributes 側で上書き
      }
    } else {
      // 通常キー
      out[key] = v;
    }
  }
  return out;
}
