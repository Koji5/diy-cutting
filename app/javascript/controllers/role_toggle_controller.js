import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo"

export default class extends Controller {
  static values = {
    role: String
  }

  async toggle(event) {
    const loader = document.getElementById("nowloading")
    loader?.classList.add("is-active")
    const checkbox = event.target
    const url = "/accounts/toggle_role"; // ← 固定URLをここに直書き

    try {
      const response = await fetch(url, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "text/vnd.turbo-stream.html",
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          role: this.roleValue,
          enabled: checkbox.checked
        })
      });

      const html = await response.text();

      if (response.ok) {
        Turbo.renderStreamMessage(html);
      } else if (response.status === 422) {
        // 422 → エラーメッセージのみを含む Turbo Stream が返ってきた前提
        Turbo.renderStreamMessage(html);
        // ✅ 状態を操作前に戻す（反転させる）
        checkbox.checked = !checkbox.checked
      } else {
        // その他のエラー
        console.error(`Unexpected error (${response.status})`, html);
      }
    } catch (error) {
      console.error("Network error", error)
    } finally {
      // ✅ 終了時に .is-active を削除
      loader?.classList.remove("is-active")
    }
  }
}
