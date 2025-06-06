import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { shapes: Object }   // { "RECT":["t","l",…], … }
  static targets = [
    "shape",             // 形状セレクト (外側ラッパーで共有)
    "tlSelect","tSelect","trSelect",
    "lSelect",          "rSelect",
    "blSelect","bSelect","brSelect"
  ]

   connect() {
    // 👇 追加：共通 JSON から edge 用ルールを取り出す
    if (!this.hasShapesValue) {
      const rules = JSON.parse(this.element.dataset.allshapesValue)
      this.shapesValue = rules.edge
    }
    this.refresh()
   }

   shapeChanged() { this.refresh() }

  /** 形状ごとにセレクト活性/非活性 */
  refresh() {
    const allowed = this.shapesValue[this.shapeTarget.value] || []
    ;["tl","t","tr","l","r","bl","b","br"].forEach(key => {
      const sel = this[`${key}SelectTarget`]
      const enable = allowed.includes(key)
      sel.disabled = !enable
      if (!enable) sel.value = "NONE"
    })
  }
}
