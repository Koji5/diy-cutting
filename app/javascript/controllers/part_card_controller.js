// app/javascript/controllers/part_card_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  disconnect() {
    // Turbo Stream remove で要素が DOM から外れた瞬間に呼ばれる
    const loader = this.application.getControllerForElementAndIdentifier(
      document.body,
      "page-loading"
    )
    if (loader && typeof loader.hide === "function") {
      loader.hide()
    }
  }
}
