// part_list_toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { partId: Number }
  static targets = ["header", "body", "container"]

  connect() {

    // 非同期読み込みだけ先に開始（ローディング表示はしない）
    this.fetchPromise = this._loadPartContent()
      .then(() => {
        requestAnimationFrame(() => {
          this.containerTarget.classList.remove("loading-placeholder")
        })
      })
      .catch(err => {
        console.error(err)
      })
  }

  toggle(event) {
    const icon = this.headerTarget.querySelector("i")
    const isOpen = this.bodyTarget.classList.contains("show")

    if (isOpen) {
      this.bodyTarget.classList.remove("show")
      icon.classList.replace("bi-chevron-up", "bi-chevron-down")
      this.headerTarget.classList.remove("rounded-top")
      this.element.classList.add("rounded")
    } else {
      this.bodyTarget.classList.add("show")
      icon.classList.replace("bi-chevron-down", "bi-chevron-up")
      this.headerTarget.classList.add("rounded-top")
      this.element.classList.remove("rounded")
    }
  }

  _loadPartContent() {
    return fetch(`/parts/${this.partIdValue}/inline_detail`)
      .then(response => response.text())
      .then(html => {
        this.containerTarget.innerHTML = html
      })
      .catch(err => {
        console.error("読み込み失敗:", err)
      })
  }
}
