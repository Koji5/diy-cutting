// app/javascript/controllers/dims_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "shape", "width2Wrap", "width1", "width2", "length",
    "autoLengthNote"               // ← 追加
  ]

  connect() { this.refresh() }

  shapeChanged() { this.refresh() }
  width1Changed() { this.updateLength() }

  refresh() {
    const shape = this.shapeTarget.value
    const autoShapes = ["TRI_EQ", "CIRC", "SEMI", "CORNER_TRI"]

    // 巾2 表示
    this.width2WrapTarget.classList.toggle("d-none", shape !== "NICHE")
    if (shape !== "NICHE") this.width2Target.value = ""

    // 長さ readOnly & バッジ表示
    const isAuto = autoShapes.includes(shape)
    this.lengthTarget.readOnly = isAuto
    this.autoLengthNoteTarget.classList.toggle("d-none", !isAuto)

    this.updateLength()
  }

  updateLength() {
    const shape = this.shapeTarget.value
    const w = parseFloat(this.width1Target.value) || 0

    switch (shape) {
      case "TRI_EQ":   // 高さ→一辺
        this.lengthTarget.value = w ? Math.round(2 * w / Math.sqrt(3)) : ""
        break
      case "CIRC":     // 直径
        this.lengthTarget.value = w || ""
        break
      case "SEMI":     // 2×半径
        this.lengthTarget.value = w ? Math.round(2 * w) : ""
        break
      case "CORNER_TRI": // r√2
        this.lengthTarget.value = w ? Math.round(w * Math.SQRT2) : ""
        break
      default:
        // 自動入力対象外
        break
    }
  }
}
