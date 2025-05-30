// app/javascript/controllers/dims_controller.js
import { Controller } from "@hotwired/stimulus"
import { evalExpr } from "lib/eval_expr"

export default class extends Controller {
  /* -------------------------------- targets & values ------------------------------- */
  static targets = [
    "shape", "width2Wrap", "width1", "width2", "length", "autoLengthNote"
  ]
  static values = {
    rules: Object,
    holeDiameters: Object
  }

  /* -------------------------------- lifecycle -------------------------------------- */
  connect () {
    this.refresh()
    this.addListeners()
    this.showAllHints()  // 初期表示時にヒント描画
    // >>> ADD: 空の number フィールドにフォーカスしたら min を自動入力
    this.element
      .querySelectorAll('input[type="number"]')
      .forEach(el => el.addEventListener("focus", this.fillMinIfBlank))
  }
  // >>> ADD
  fillMinIfBlank = (event) => {
    const input = event.currentTarget
    if (input.value !== "") return            // 既に値があれば何もしない

    const minAttr = input.getAttribute("min")
    if (minAttr == null) return              // min が無ければスキップ

    input.value = minAttr                    // min をセット
    // Vue / React と同等に Turbo へ変更通知
    input.dispatchEvent(new Event("input", { bubbles: true }))
  }
  // disconnect で後片付けしたい場合（任意）
  disconnect () {
    this.element
      .querySelectorAll('input[type="number"]')
      .forEach(el => el.removeEventListener("focus", this.fillMinIfBlank))
  }
  /* -------------------------------- UI handlers ------------------------------------ */
  shapeChanged () {
    this.refresh()
    this.checkAll()
  }
  width1Changed () {
    this.updateLength()
    this.checkAll()
  }

  /* -------------------------------- view helpers ----------------------------------- */
  refresh () {
    const shape = this.shapeTarget.value
    const autoShapes = ["TRI_EQ", "CIRC", "SEMI", "CORNER_TRI"]

    // 巾2 表示切替
    this.width2WrapTarget.classList.toggle("d-none", shape !== "NICHE")
    if (shape !== "NICHE") this.width2Target.value = ""

    // 長さ 自動入力切替
    const isAuto = autoShapes.includes(shape)
    this.lengthTarget.readOnly = isAuto
    this.autoLengthNoteTarget.classList.toggle("d-none", !isAuto)

    this.updateLength()
    this.showAllHints() // shape 変更時にもヒント再評価
  }

  updateLength () {
    const shape = this.shapeTarget.value
    const w     = parseFloat(this.width1Target.value) || 0

    switch (shape) {
      case "TRI_EQ":   this.lengthTarget.value = w ? Math.round(2 * w / Math.sqrt(3)) : ""; break
      case "CIRC":     this.lengthTarget.value = w || "";                                   break
      case "SEMI":     this.lengthTarget.value = w ? Math.round(2 * w) : "";                break
      case "CORNER_TRI": this.lengthTarget.value = w ? Math.round(w * Math.SQRT2) : "";     break
    }
  }

  /* -------------------------------- event wiring ----------------------------------- */
  addListeners () {
    const inputs = this.element.querySelectorAll("input, select")
    inputs.forEach(el => {
      el.addEventListener("input", () => this.checkAll())
    })
  }

  /* -------------------------------- hint helpers ----------------------------------- */
  showAllHints () {
    const ctx       = this.buildContext()
    const fields    = this.rulesValue.fields   || {}
    const dynamics  = this.rulesValue.dynamic || []

    const hinted = new Set()

    // dynamic が優先
    dynamics.forEach(r => {
      if (r.if && !evalExpr(r.if, ctx)) return
      const input = this.element.querySelector(`[name='part[${r.target}]']`)
      if (!input) return

      const min = evalExpr(r.min_expr, ctx)
      const max = evalExpr(r.max_expr, ctx)
      if (min != null && max != null && min > max) return // 異常値はスキップ

      this.showHint(input, { min, max })
      hinted.add(r.target)
    })

    // fields (dynamic と重複しないもののみ)
    Object.entries(fields).forEach(([attr, cfg]) => {
      if (hinted.has(attr)) return
      const input = this.element.querySelector(`[name='part[${attr}]']`)
      if (input) this.showHint(input, cfg)
    })
  }

  showHint (input, cfg) {
    if (!input) return
    this.removeHints(input)
    if (cfg.min != null && cfg.max != null) {
      const hint = document.createElement("div")
      hint.className = "form-text text-muted"
      hint.textContent = `${Math.round(cfg.min)}～${Math.round(cfg.max)}mmで入力`
      input.after(hint)
    }
  }

  /* -------------------------------- validation core -------------------------------- */
  checkAll () {
    this.clearAllFeedback()
    this.checkFields()
    this.checkDynamic()
    this.checkRelations()
    this.showAllHints()
  }

  checkFields () {
    const ctx    = this.buildContext()
    const fields = this.rulesValue.fields || {}

    Object.entries(fields).forEach(([attr, cfg]) => {
      const input = this.element.querySelector(`[name='part[${attr}]']`)
      if (!input) return

      // 属性反映で矢印 step 制御
      if (cfg.min != null) input.setAttribute("min", cfg.min)
      if (cfg.max != null) input.setAttribute("max", cfg.max)
      input.setAttribute("step", 1)

      const value    = input.value
      const required = cfg.required || (cfg.required_if && evalExpr(cfg.required_if, ctx))
      const errors   = []

      if (required && !value.trim()) {
        errors.push("入力してください")
      } else if (value) {
        const f = parseFloat(value)
        if (cfg.min != null && cfg.max != null && (f < cfg.min || f > cfg.max)) {
          errors.push(`${cfg.min}～${cfg.max}mm にしてください`)
        } else {
          if (cfg.min != null && f < cfg.min) errors.push(`${cfg.min}mm 以上にしてください`)
          if (cfg.max != null && f > cfg.max) errors.push(`${cfg.max}mm 以下にしてください`)
        }
      }

      this.showValidation(input, errors)
    })
  }

  checkDynamic () {
    const ctx  = this.buildContext()
    const list = this.rulesValue.dynamic || []

    list.forEach(r => {
      if (r.if && !evalExpr(r.if, ctx)) return
      const input = this.element.querySelector(`[name='part[${r.target}]']`)
      if (!input) return

      const val = parseFloat(input.value)
      if (isNaN(val)) return

      const min = evalExpr(r.min_expr, ctx)
      const max = evalExpr(r.max_expr, ctx)

      // 異常 min>max はスキップ（ログ）
      if (min != null && max != null && min > max) {
        console.warn("[dims] skip dynamic min>max", r.target, { min, max, ctx })
        return
      }

      // 入力属性に反映
      if (min != null) input.setAttribute("min", min)
      if (max != null) input.setAttribute("max", max)
      input.setAttribute("step", 1)

      const errors = []
      if (min != null && max != null && (val < min || val > max)) {
        errors.push(`${Math.round(min)}～${Math.round(max)}mm にしてください`)
      } else {
        if (min != null && val < min) errors.push(`${min}mm 以上にしてください`)
        if (max != null && val > max) errors.push(`${max}mm 以下にしてください`)
      }

      this.showValidation(input, errors)
    })
  }

  checkRelations () {
    const ctx  = this.buildContext()
    const list = this.rulesValue.relations || []

    list.forEach(rel => {
      if (rel.if && !evalExpr(rel.if, ctx)) return
      const ok = evalExpr(rel.expr, ctx)
      if (ok) return

      const message = rel.message || "寸法の組み合わせが正しくありません"
      const input   = this.element.querySelector("[name='part[length_mm]']") || this.width1Target
      if (input) this.showValidation(input, [message])
    })
  }

  showValidation (input, errors) {
    if (!input) return
    this.removeFeedback(input)
    this.removeHints(input)

    if (errors.length) {
      input.classList.add("is-invalid")
      const div = document.createElement("div")
      div.className = "invalid-feedback"
      div.textContent = errors[0]
      input.after(div)
    } else {
      input.classList.remove("is-invalid")
    }

    // 末尾に再ヒント
    const attr = input.name.match(/\[([^\]]+)\]/)?.[1]
    const cfg  = this.rulesValue.fields?.[attr]
    if (cfg) this.showHint(input, cfg)
  }

  /* -------------------------------- DOM cleanup helpers ----------------------------- */
  removeHints (input) {
    if (!input) return
    let el = input.nextElementSibling
    while (el && el.classList.contains("form-text")) {
      const nxt = el.nextElementSibling; el.remove(); el = nxt
    }
  }

  removeFeedback (input) {
    if (!input) return
    input.classList.remove("is-invalid")
    let el = input.nextElementSibling
    while (el && el.classList.contains("invalid-feedback")) {
      const nxt = el.nextElementSibling; el.remove(); el = nxt
    }
  }

  clearAllFeedback () {
    this.element.querySelectorAll("input, select").forEach(el => {
      this.removeFeedback(el)
      this.removeHints(el)
    })
  }

  /* -------------------------------- context builder -------------------------------- */
  buildContext () {
    const ctx = {}

    // ① フォーム値を ctx へ（数値を数値化）
    for (const [key, val] of new FormData(this.element).entries()) {
      const m = key.match(/^part\[(.+)\]$/);
      if (!m) continue;
      const num = parseFloat(val);
      ctx[m[1]] = isNaN(num) ? val : num;
    }

    // ② 補助キーを補完
    /** 配列は 1 度だけ定義し再利用 */
    const pos = ["tl", "tr", "bl", "br"];

    // --- 丸穴 (mm または code→mm 変換) ---
    pos.forEach(p => {

      /* ---------- ① まず code を ctx に保存 ---------- */
      const codeInput = this.element.querySelector(
        `[name="part[hole_${p}_dia_code]"]`
      )
      ctx[`hole_${p}_dia_code`] = codeInput ? codeInput.value : null

      const diaKey = `hole_${p}_dia_mm_or_code`;

      // ① 自由入力 mm を優先
      const inputMm = parseFloat(ctx[`hole_${p}_dia_mm`] || "");
      if (!isNaN(inputMm)) {
        ctx[diaKey] = inputMm;
      } else {
        // ② プルダウン選択の code を mm に変換
        const code = ctx[`hole_${p}_dia_code`];
        ctx[diaKey] = this.holeDiametersValue[code] || 0;   // ← 事前に渡したマップを参照
      }

      // ③ フラグを true/false に正規化
      ctx[`hole_${p}_flag`] = !!ctx[`hole_${p}_flag`];
    });

    // --- コーナー ---
    pos.forEach(p => {
      const codeKey = `corner_${p}_code`;
      if (!(codeKey in ctx)) ctx[codeKey] = "";

      (['r','dx','dy']).forEach(prop => {
        const k = `corner_${p}_${prop}`;
        if (!(k in ctx)) {
          ctx[k] = 0;
        } else {
          const n = parseFloat(ctx[k]);
          ctx[k] = isNaN(n) ? 0 : n;
        }
      });
    });

    // ③ Math ユーティリティ
    ctx.round = Math.round;
    ctx.sqrt  = Math.sqrt;

    return ctx;
  }
}
