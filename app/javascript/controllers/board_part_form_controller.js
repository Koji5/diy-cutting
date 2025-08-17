import { Controller } from "@hotwired/stimulus"
import { formToJSON } from "lib/serialize_form";

export default class extends Controller {
  connect() {
    this.boardEl = document.querySelector('[data-controller~="board-part3d"]')
    this.boardPart3dCtrl = this.boardEl
      ? this.application.getControllerForElementAndIdentifier(this.boardEl, "board-part3d")
      : null
    this.form = this.element.closest("form") || document.forms[0]
    // 解除用にハンドラを束ねておく
    this._onInput = () => this._updateForm()
    this.form.addEventListener("input", this._onInput)
    this._onResize = () => {
      cancelAnimationFrame(this._rafId)
      this._rafId = requestAnimationFrame(() => this._resizeWork())
    }

    window.addEventListener("resize", this._onResize)
    this._resizeWork()
  }

  disconnect() {
    this.form?.removeEventListener("input", this._onInput)
    window.removeEventListener("resize", this._onResize)
    cancelAnimationFrame(this._rafId)
  }

  _updateForm(){
    // ✨ 相手が未初期化の可能性に備える
    if (!this.boardPart3dCtrl && this.boardEl) {
      this.boardPart3dCtrl =
        this.application.getControllerForElementAndIdentifier(this.boardEl, "board-part3d")
    }
    const formJSON = formToJSON(this.form)
    console.log(formJSON)
    this.boardPart3dCtrl?.updateModel?.(formJSON)
  }

  _resizeWork() {
    // 実際のサイズ調整ロジック（例：高さ=50dvh−Header−Bottom）
    const header = document.querySelector(".MainHeader")
    const bottom = document.querySelector(".BottomBar")
    const canvas = document.querySelector(".square-half")

    const headerH =
      header && getComputedStyle(header).display !== "none"
        ? header.getBoundingClientRect().height
        : 0
    console.log("headerH", headerH)
    const bottomH =
      bottom && getComputedStyle(bottom).display !== "none"
        ? bottom.getBoundingClientRect().height
        : 0
    console.log("bottomH", bottomH)
    const canvasH =
      canvas && getComputedStyle(canvas).display !== "none"
        ? canvas.getBoundingClientRect().height
        : 0
    console.log("canvasH", canvasH)
    const targetH = Math.max(0, Math.round(window.innerHeight - canvasH - headerH - bottomH -10))
    console.log("targetH", targetH)
    const el = document.querySelector(".carousel-inner")
    if (el) el.style.height = `${targetH}px`
  }
}
