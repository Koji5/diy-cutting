/*
 * build_ctx.js — ctx 生成ユーティリティ (左下原点版)
 * --------------------------------------------------
 *  原点 : 左下 (0,0)
 *  X軸 : 右(+) = 長さ方向  L (length_mm)
 *  Y軸 : 上(+) = 巾方向    W (width1_mm)
 *  外周 : 時計回り (CW)
 *
 *  フォーム name 一覧 (想定)
 *  --------------------------------------------------
 *  基本寸法    : length_mm, width1_mm, width2_mm, thickness_mm, shape_code
 *  形状アール  : shape_tl_r, shape_tr_r, shape_bl_r, shape_br_r
 *  コーナー加工: corner_{tl|tr|bl|br}_code  (NONE / ROUND_R / CHAMFER / BEVEL / INROUND)
 *                 corner_{pos}_r, corner_{pos}_dx, corner_{pos}_dy
 *  丸穴         : hole_{pos}_flag (checkbox) , hole_{pos}_dx, hole_{pos}_dy , hole_{pos}_dia_mm_or_code
 *  四角穴       : sqhole_{pos}_flag (checkbox) , sqhole_{pos}_dx , sqhole_{pos}_dy , sqhole_{pos}_w , sqhole_{pos}_h
 *  --------------------------------------------------
 */

const $ = (form, name) => 
  form.elements[name] ||
  form.elements[`part[${name}]`] ||
  form.querySelector(`[name$="[${name}]"]`);

  /** 丸穴中心計算 (左上基準は W-dy) */
function posRound (pos, dx, dy, L, W) {
  switch (pos) {
    case "tl": return { cx: dx,          cy: W - dy };
    case "tr": return { cx: L - dx,     cy: W - dy };
    case "bl": return { cx: dx,          cy: dy     };
    case "br": return { cx: L - dx,     cy: dy     };
  }
}

/** 四角穴中心計算 */
function posRect (pos, dx, dy, w, h, L, W) {
  switch (pos) {
    case "tl": return { cx: dx + w/2,        cy: W - dy - h/2 };
    case "tr": return { cx: L - dx - w/2,    cy: W - dy - h/2 };
    case "bl": return { cx: dx + w/2,        cy: dy + h/2     };
    case "br": return { cx: L - dx - w/2,    cy: dy + h/2     };
  }
}

/**
 * buildCtx(form): HTMLFormElement → ctx オブジェクト
 */
export function buildCtx (form) {
  const v = (form, n) => {
    const el = $(form, n);
    return el ? parseFloat(el.value) || 0 : 0;
  };
  const flag = (form, n) => {
    // 末尾が [hole_tl_flag] などのチェックボックスを探す
    const cb = form.querySelector(`input[type="checkbox"][name$="[${n}]"]`);
    if (cb) return cb.checked;       // チェック済みなら true
    // fallback: 最初に見つかった input (hidden など)
    const el = form.elements[`part[${n}]`] || form.elements[n];
    return !!el?.checked;             // hidden は undefined -> false
  };
  const shapeEl = $(form, "shape_code");            // ← $() で両対応
  const shape   = shapeEl ? shapeEl.value : "RECT"; // Fallback はそのまま

  // --- 共通フィールド -----------------------------------------------
  const ctx   = { shapeCode: shape, T: v(form, "thickness_mm") };
  ctx.W1      = v(form, "width1_mm");         // 巾1 は必ずフォームにある

  // --- shapeCode 別の L / W2 / 角パラメータ ------------------------
  switch (shape) {
    case "RECT":
    case "CORNER_R1":
    case "CORNER_R2":
    case "CORNER_R4":
    case "SIDE_ARC1":
    case "SIDE_UARC1":
    case "SIDE_UARC2":
      ctx.L  = v(form, "length_mm");
      break;

    case "CIRC":
      ctx.L  = ctx.W1;                  // 正方形
      break;

    case "SEMI":
      ctx.L  = ctx.W1 * 2;              // 直径
      break;

    case "TRI_EQ":
      ctx.L  = ctx.W1 * 2 / Math.sqrt(3); // 底辺 (自動)
      break;

    case "NICHE":
      ctx.L  = v(form, "length_mm");
      ctx.W2 = v(form, "width2_mm");
      break;

    case "CORNER_TRI":
      ctx.L  = ctx.W1;                  // 辺長 = 巾
      break;
  }

  // --- 4 隅のコーナー加工 ------------------------------------------
  const cornerCfg = pos => {
    const code = $(form, `corner_${pos}_code`)?.value || "NONE";
    if (code === "NONE") {
      return { code:"NONE", r:0, dx:0, dy:0 };      // ← 直角で固定
    }
    // code が ROUND_R / INROUND / CHAMFER / BEVEL のときだけ値を読む
    return {
      code,
      r  : v(form, `corner_${pos}_r`),
      dx : v(form, `corner_${pos}_dx`),
      dy : v(form, `corner_${pos}_dy`)
    };
  };
  ctx.corners = { tl: cornerCfg("tl"), tr: cornerCfg("tr"),
                  bl: cornerCfg("bl"), br: cornerCfg("br") };

  /* shapeCode 固有の上書き例 --------------------------------------- */
  switch (shape) {

    case "CORNER_R1":          // 左下だけ shape_bl_r を使う
      ctx.corners.bl.r = ctx.corners.bl.r || v(form,"shape_bl_r");
      break;

    case "SIDE_ARC1":          // 左上・左下を外周R
      ctx.corners.tl.r = ctx.corners.tl.r || v(form,"shape_tl_r");
      ctx.corners.bl.r = ctx.corners.bl.r || v(form,"shape_bl_r");
      break;

    case "SIDE_UARC1":         // 左側U = W1/2
      const Ru = ctx.W1 / 2;
      ctx.corners.tl.r ||= Ru;
      ctx.corners.bl.r ||= Ru;
      break;

    case "CORNER_R2":          // 左下・右下 = 外周R
      ctx.corners.bl.r = ctx.corners.bl.r || v(form,"shape_bl_r");
      ctx.corners.br.r = ctx.corners.br.r || v(form,"shape_br_r");
      break;

    case "CORNER_R4":          // 四隅とも外周R
      ["tl","tr","bl","br"].forEach(p=>{
        ctx.corners[p].r ||= v(form,`shape_${p}_r`);
      });
      break;

    case "SIDE_UARC2":         // 両側U = W1/2
      const R2 = ctx.W1 / 2;
      ["tl","tr","bl","br"].forEach(p=> ctx.corners[p].r ||= R2);
      break;

    case "CIRC":               // 四隅とも直径/2
      const Rc = ctx.W1 / 2;
      ["tl","tr","bl","br"].forEach(p=> ctx.corners[p].r ||= Rc);
      break;

    case "SEMI":               // 下辺 2 角 = 半径 (=W1)
      ctx.corners.bl.r ||= ctx.W1;
      ctx.corners.br.r ||= ctx.W1;
      break;

    case "NICHE":              // 下辺 2 角 = corner_bl_r / corner_br_r
      // 既に v(form, corner_bl_r) で入っているはず
      break;

    case "CORNER_TRI":         // 左下 = W1 (半径) / 右上 = corner_tr_r
      ctx.corners.bl.r ||= ctx.W1;
      break;
  }
  // --- エッジ加工 (edge_{key}_code) ---------------------------------
  const EDGE_KEYS = ["tl","t","tr","l","r","bl","b","br"];
  ctx.edges = {}; 
  EDGE_KEYS.forEach(key=>{
    const raw = ($(form, `edge_${key}_code`)?.value || "NONE").toUpperCase();
    ctx.edges[key] = { code: raw, opts: {} };
  });

  // --- 丸穴 ----------------------------------------------------------
  // フォーム data-attribute から直径テーブルを取得
  const DIA = (() => {
    try { return JSON.parse(form.dataset.dimsHoleDiametersValue || "{}"); }
    catch { return {}; }
  })();
  const diaOf = raw => (DIA[raw] ?? parseFloat(raw)) || 0;
  ctx.holes_round = [];
  ["tl","tr","bl","br"].forEach(pos=>{
    if (!flag(form, `hole_${pos}_flag`)) return;
    const dx  = v(form, `hole_${pos}_dx`);
    const dy  = v(form, `hole_${pos}_dy`);
    /* ---- 直径コード or mm を取得 -------------------------------- */
    const rawCode = $(form, `hole_${pos}_dia_code`)?.value || "";
    const rawMM   = $(form, `hole_${pos}_dia_mm`)?.value   || "";
    const raw     = rawCode.toUpperCase() === "D16P" ? rawMM : rawCode;
    const dia     = diaOf(raw);                      // "D08"→8.0, "12"→12.0
    if (!dia) return;
    const {cx,cy} = posRound(pos, dx, dy, ctx.L, ctx.W1);
    ctx.holes_round.push({ pos, cx, cy, r: dia/2 });
  });

  // --- 四角穴 --------------------------------------------------------
  ctx.holes_square = [];
  ["tl","tr","bl","br"].forEach(pos=>{
    if (!flag(form, `sqhole_${pos}_flag`)) return;
    const dx = v(form, `sqhole_${pos}_dx`);
    const dy = v(form, `sqhole_${pos}_dy`);
    const w  = v(form, `sqhole_${pos}_w`);
    const h  = v(form, `sqhole_${pos}_h`);
    if (!w || !h) return;
    const {cx,cy} = posRect(pos, dx, dy, w, h, ctx.L, ctx.W1);
    ctx.holes_square.push({ pos, cx, cy, w, h });
  });

  // --- ctx 出力 ------------------------------------------------------
  return ctx;
}
