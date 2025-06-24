// app/javascript/controllers/part_show_modal_controller.js
import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {

  connect() {
    console.log("✅ connect");
    this.modal = bootstrap.Modal.getOrCreateInstance(this.element)
  }

  open () {
    console.log("✅ open called");
    this.modal.show()
    console.log("✅ show() executed");
    setTimeout(() => {
      console.log("isShown?", this.modal._isShown)          // ← true なら JS 側OK
    }, 100)
    // フェード終了後 1 回だけ後処理
    this.element.addEventListener(
      "shown.bs.modal",
      () => this.afterShow(),
      { once: true }
    )
  }

  afterShow = () => {
    const el = this.element.querySelector("[data-controller~='part-show']")
    console.log("✅ el:", el);
    const part3d = this.application.getControllerForElementAndIdentifier(el, "part-show")
    console.log("✅ part3d:", part3d);
    part3d?.refresh()
  }
}
