// app/javascript/controllers/accordion_state_controller.js
import { Controller } from "@hotwired/stimulus"

/*
  data-controller="accordion-state"
  ╭──────────────────────────╮
  │ data-accordion-id="XXX" │ ← アコーディオンごとにユニーク ID を付与
  ╰──────────────────────────╯
*/
export default class extends Controller {
  static values = { id: String }

  connect () {
    if (!this.hasIdValue) return
    this.restoreState()
    this.element.addEventListener("show.bs.collapse", () => this.saveState(true))
    this.element.addEventListener("hide.bs.collapse", () => this.saveState(false))
  }

  // 保存
  saveState (isOpen) {
    localStorage.setItem(this.storageKey(), isOpen ? "1" : "0")
  }

  // 復元
  restoreState () {
    const state = localStorage.getItem(this.storageKey())
    if (state === "1") {
      const collapse = bootstrap.Collapse.getOrCreateInstance(this.element)
      collapse.show()
    }
  }

  storageKey () {
    return `accordionState:${this.idValue}`
  }
}
