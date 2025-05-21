// app/javascript/controllers/flash_toast_controller.js
import { Controller } from "@hotwired/stimulus"
import "bootstrap"                    // importmap で pin 済み前提
const bs = window.bootstrap

export default class extends Controller {
  connect() {
    bs.Toast.getOrCreateInstance(this.element).show()
    // delay / autohide は data-bs-* 属性で済ませているので
    // オプションは渡さなくて OK
  }
}
