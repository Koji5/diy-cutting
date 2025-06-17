import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]
  pending = new Set()

  connect() {
    /* --- Visit 開始：とりあえず is-active を付ける ---- */
    addEventListener("turbo:before-visit",        () => this.show())
    addEventListener("turbo:before-fetch-request", (e) => {
      const headers = e.detail.fetchOptions.headers || {};
      // ↓ prefetch 判定：Purpose, Sec-Purpose, X-Sec-Purpose いずれかが "prefetch"
      const isPrefetch =
        headers["Purpose"] === "prefetch" ||
        headers["Sec-Purpose"] === "prefetch" ||
        headers["X-Sec-Purpose"] === "prefetch";
      console.log(e.detail.fetchOptions);
      if (isPrefetch) return;   // ← ホバーによる先読みは無視

      this.show();              // 実際の遷移・フォーム送信だけオーバーレイ表示
    });
    /* --- 本番 HTML が描画された瞬間 ---------------------- */
    addEventListener("turbo:render", (e) => {
      // preview (= キャッシュ) ならスルー
      if (document.documentElement.hasAttribute("data-turbo-preview")) return
      this.show()                // ② ここで CSS => JS に引き継ぐ
      // 1フレーム待って pending が無ければ即 hide
      requestAnimationFrame(() => { if (this.pending.size === 0) this.hide() })
    })

    /* --- 422/500 などエラー応答 -------------------------- */
    addEventListener("turbo:before-fetch-response", (e) => {
      if (e.detail.fetchResponse.response.status >= 400) this.hide()
    })

    /* --- Promise 完了通知 ------------------------------- */
    addEventListener("page-loading:done", ({ detail: promise }) => {
      this.pending.delete(promise)
      if (this.pending.size === 0) this.hide()    // ③
    })
  }

  /* --- 外部から Promise を登録する API ------------------ */
  register(promise) {
    this.pending.add(promise)
    promise.finally(() =>
      dispatchEvent(new CustomEvent("page-loading:done", { detail: promise }))
    )
  }

  show() { this.overlayTarget.classList.add("is-active") }
  hide() { this.overlayTarget.classList.remove("is-active") }
}
