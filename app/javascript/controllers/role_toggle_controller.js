import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    role: String
  }

  toggle(event) {
    const url = "/accounts/toggle_role"; // ← 固定URLをここに直書き

    fetch(url, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "text/vnd.turbo-stream.html",
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        role: this.roleValue,
        enabled: event.target.checked
      })
    })
  }
}
