import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["body"]
  static values = { role: String }

  toggle(event) {
    const body = this.bodyTarget
    const isCollapsed = body.classList.contains("show")

    body.classList.toggle("show", !isCollapsed)

    // アイコンを上下反転（BootstrapのChevron）
    const icon = this.element.querySelector(".toggle-icon")
    if (icon) {
      icon.classList.toggle("bi-chevron-down", isCollapsed)
      icon.classList.toggle("bi-chevron-up", !isCollapsed)
    }
  }
}
