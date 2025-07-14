// app/javascript/controllers/flash_toast_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    try {
      const Toast = window?.bootstrap?.Toast
      console.log("📦 window.bootstrap.Toast =", Toast)
      if (!Toast) throw new Error("Toast is undefined")
      const toast = Toast.getOrCreateInstance(this.element)
      toast.show()
      console.log("✅ Toast shown")
    } catch (error) {
      console.error("❌ Error in flash_toast_controller:", error)
      console.error("🧩 this.element:", this.element)
    }
  }
}
