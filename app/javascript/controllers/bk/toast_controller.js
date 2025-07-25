import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const toast = new bootstrap.Toast(this.element)
    toast.show()

    this.element.addEventListener("hidden.bs.toast", () => {
      this.element.remove()
    })
  }
}
