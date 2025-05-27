import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "shape", "tlWrap", "trWrap", "blWrap", "brWrap",
    "tl", "tr", "bl", "br", "noneMsg"
  ]
  static values = { shapes: Object }   // ← 追加

  connect() { this.update() }
  shapeChanged() { this.update() }

  update() {
    const shape = this.shapeTarget.value
    const allowed = this.shapesValue[shape] || []

    this.toggleCorner("tl", allowed.includes("tl"))
    this.toggleCorner("tr", allowed.includes("tr"))
    this.toggleCorner("bl", allowed.includes("bl"))
    this.toggleCorner("br", allowed.includes("br"))

    this.noneMsgTarget.classList.toggle("d-none", allowed.length > 0)
  }

  toggleCorner(key, show) {
    const wrap = this[`${key}WrapTarget`]
    wrap.classList.toggle("d-none", !show)
    if (!show) this[`${key}Target`].value = ""
  }
}
