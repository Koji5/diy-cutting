// app/javascript/controllers/tab_pause_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // 表示されたとき
    this.element.addEventListener("shown.bs.tab", (e) => {
      const selector = e.target.dataset.bsTarget || e.target.getAttribute("href")
      if (!selector) return                // どちらも無ければ何もしない
      const pane = document.querySelector(selector)
      if (!pane) return
      pane.querySelectorAll("[data-controller~='part3d']")
          .forEach(el => this.application
                            .getControllerForElementAndIdentifier(el, "part3d")
                            ?.start())
    })

    // 隠れたとき
    this.element.addEventListener("hidden.bs.tab", (e) => {
      const selector = e.target.dataset.bsTarget || e.target.getAttribute("href")
      if (!selector) return

      const pane = document.querySelector(selector)
      if (!pane) return
      pane.querySelectorAll("[data-controller~='part3d']")
          .forEach(el => this.application
                            .getControllerForElementAndIdentifier(el, "part3d")
                            ?.stop())
    })
  }
}
