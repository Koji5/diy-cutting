import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  connect() {
    this.modal = bootstrap.Modal.getOrCreateInstance(this.element)
  }

  open () {
    this.modal.show()

    const trigger = document.activeElement

    // タイトル変更
    const title = trigger?.dataset?.modalTitle
    const titleEl = this.element.querySelector("#modalTitle")
    if (title && titleEl) titleEl.textContent = title

    // サイズ変更（modal-lg / modal-xl / など）
    const size = trigger?.dataset?.modalSize
    const dialog = this.element.querySelector("#modalDialog")
    if (dialog && size) {
      dialog.classList.remove("modal-sm", "modal-md", "modal-lg", "modal-xl")
      dialog.classList.add(size)
    }

    // ボディクラスの変更
    const bodyClass = trigger?.dataset?.modalBodyClass
    const bodyEl = this.element.querySelector("#modalBody")
    if (bodyEl && bodyClass) {
      bodyEl.className = `modal-body ${bodyClass}`
    }

    setTimeout(() => {
      console.log("isShown?", this.modal._isShown)          // ← true なら JS 側OK
    }, 100)
  }

  // Turboが再ロードされた（＝submit成功）ときに閉じる
  autoClose() {
    console.log("✅ autoClose triggered")
    this.modal.hide()
  }
}
