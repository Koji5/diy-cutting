// cornerproc_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values  = { shapes: Object, proc: Object }
  static targets = [
    "shape",
    "tlSelect", "trSelect", "blSelect", "brSelect",
    "tlRWrap", "trRWrap", "blRWrap", "brRWrap",
    "tlDxDyWrap", "trDxDyWrap", "blDxDyWrap", "brDxDyWrap"
  ]

  connect () { this.updateForShape() }

  shapeChanged () { this.updateForShape() }
  procChanged   (e) { this.updateParams(e.target) }

  /** 形状に応じて 4 角セレクトの活性/非活性を切替 */
  updateForShape () {
    const allowed = this.shapesValue[this.shapeTarget.value] || []

    ;["tl","tr","bl","br"].forEach(key => {
      const select = this[`${key}SelectTarget`]
      const enable = allowed.includes(key)

      if (enable) {
        select.disabled = false
      } else {
        // 非許可角 → 「加工しない」で固定 & disabled
        select.value    = "NONE"
        select.disabled = true
        this.hideParam(key)              // パラメータ欄も非表示
      }
      // 許可角の場合は選択済み値に合わせてパラメータ更新
      if (enable) this.updateParams(select)
    })
  }

  /** セレクト変更時に R / dx dy 入力を出し分け */
  updateParams (select) {
    const key   = select.name.match(/corner_(..)_code/)[1]   // tl 等
    const allow = this.procValue[select.value] || []

    this.hideParam(key)  // まず全部隠す

    if (allow.includes("r")) {
      this[`${key}RWrapTarget`].classList.remove("d-none")
    }
    if (allow.includes("dx")) {
      this[`${key}DxDyWrapTarget`].classList.remove("d-none")
    }
  }

  hideParam(key) {
    this[`${key}RWrapTarget`].classList.add("d-none")
    this[`${key}DxDyWrapTarget`].classList.add("d-none")
  }
}
