import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  connect() {
    this.toast = new bootstrap.Toast(this.element, { delay: 2000 })
    this.toast.show()
  }
  hide() { this.toast.hide() }
}
