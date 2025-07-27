import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    delay: { type: Number, default: 5000 }
  }

  connect() {
    document.scrollingElement?.scrollTo({ top: 0, behavior: "smooth" })
    setTimeout(() => {
      this.dismiss()
    }, this.delayValue)
  }

  dismiss() {
    this.element.style.transition = "opacity 0.6s ease"
    this.element.style.opacity = 0

    setTimeout(() => {
      this.element.remove()
    }, 600)
  }
}