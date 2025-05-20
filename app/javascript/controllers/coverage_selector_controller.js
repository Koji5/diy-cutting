import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  switch(event) {
    console.log("coverage switch!", event.target.value)  // デバッグ用
    const selected = event.target.value
    const url = `${this.urlValue}?mode=${selected}&ts=${Date.now()}` // ★追加
    fetch(url, { headers: { Accept: "text/vnd.turbo-stream.html" } })
      .then(r => r.text())
      .then(html => Turbo.renderStreamMessage(html))
  }
}
