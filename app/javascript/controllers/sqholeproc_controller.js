import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "tlFlag","trFlag","blFlag","brFlag",
    "tlDyDxWrap","trDyDxWrap","blDyDxWrap","brDyDxWrap",
    "tlHwWrap","trHwWrap","blHwWrap","brHwWrap"
  ]

  connect() { this.refresh() }

  flagChanged() { this.refresh() }

  refresh() {
    ["tl","tr","bl","br"].forEach(key => {
      const on = this[`${key}FlagTarget`].checked
      this[`${key}DyDxWrapTarget`].classList.toggle("d-none", !on)
      this[`${key}HwWrapTarget`].classList.toggle("d-none", !on)

      if (!on) {
        // 値のリセット（必要に応じて）
        this[`${key}DyDxWrapTarget`].querySelectorAll("input").forEach(i => i.value = "")
        this[`${key}HwWrapTarget`].querySelectorAll("input").forEach(i => i.value = "")
      }
    })
  }
}
