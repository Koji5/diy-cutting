import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  connect() {
    console.log("✅ connect");
    this.modal = bootstrap.Modal.getOrCreateInstance(this.element)
  }
  open () {
    this.modal.show()
  }
}