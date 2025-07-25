import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    delay: { type: Number, default: 5000 }
  }

  connect() {
    setTimeout(() => {
      this.dismiss()
    }, this.delayValue)
  }

  dismiss() {
    this.element.classList.remove("show")
    this.element.addEventListener("transitionend", () => {
      this.element.remove()
    })
  }
}