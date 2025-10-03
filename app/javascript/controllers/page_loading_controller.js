import { Controller } from "@hotwired/stimulus"

/*
  Shows an overlay (target: overlay) while Turbo navigation / requests are in flight.
  - Adds .is-active on show(), removes on hide()
  - Keeps an internal Set of pending Promises so you can call `register(promise)`
  - Provides .disableHide() / .enableHide() to prevent hide during critical phases
*/
export default class extends Controller {
  static targets = ["overlay"]
  pending = new Set()
  preventHide = false  // ← hide() を一時的に抑制したいときに使う
  _ticket = 0;
  _graceUntil = 0;
  _graceTimer = null;

  connect() {
    /* --- Turbo navigation / request start --- */
    addEventListener("turbo:before-visit", () => this.showWithTicket())
    addEventListener("turbo:before-fetch-request", (e) => {
      const headers = e.detail.fetchOptions?.headers;
      const read = (k) => headers?.get?.(k) || headers?.get?.(k.toLowerCase?.()) || headers?.[k] || headers?.[k.toLowerCase?.()] || "";
      const purpose = (read("Purpose") || read("Sec-Purpose") || read("X-Sec-Purpose")).toString().toLowerCase();
      if (!purpose.includes("prefetch")) this.showWithTicket();
    });
    addEventListener("turbo:frame-load", () => this.hide());
    addEventListener("turbo:load",       () => this.hide());
    addEventListener("page-render:done", () => this.hide());
    addEventListener("turbo:before-fetch-response", (e) => {
      if (e.detail.fetchResponse.response.status >= 400) this.hide();
    });
    addEventListener("turbo:render", () => {
      if (document.documentElement.hasAttribute("data-turbo-preview")) return;
      const t = this.showWithTicket();       // ← 新しい世代で show
      requestAnimationFrame(() => this.hide(t));
    });
  }

  /**
   * Register an external Promise.
   * The overlay will stay visible until the Promise resolves or rejects.
   */
  register(promise) {
    // ★ 0→1件目に入るタイミングで表示
    if (this.pending.size === 0 && !this.preventHide) this.showWithTicket();
    this.pending.add(promise);
    promise.finally(() => {
      this.pending.delete(promise);
      this.hide();
    });
    return promise;
  }

  /**
   * Disable automatic hide — use before long operations that should override turbo:frame-load etc.
   */
  disableHide(timeout = null) {
    this.preventHide = true
    if (timeout) {
      setTimeout(() => {
        this.preventHide = false
      }, timeout)
    }
  }

  /**
   * Re-enable automatic hide behavior
   */
  enableHide() {
    this.preventHide = false
  }

  show() {
    return this.showWithTicket();
  }

  hide = (ticket = this._ticket) => {
    if (ticket !== this._ticket) return;       // 古いhideを無効化
    if (this.preventHide) return;

    const now = performance.now();
    if (now < this._graceUntil) {              // ← グレース中は閉じない
      clearTimeout(this._graceTimer);
      this._graceTimer = setTimeout(() => this.hide(ticket), this._graceUntil - now);
      return;
    }

    if (this.pending.size > 0) return;         // ← pendingが立っていれば閉じない
    this.hideInternal(ticket);                          // 実処理へ
  };

  hideInternal = (ticket = this._ticket) => {
    if (ticket !== this._ticket || this.preventHide || this.pending.size > 0) {
      return;
    }
    const min = 160;
    const elapsed = performance.now() - (this._shownAt ?? 0);
    const doHide = () => {
      this.overlayTarget.classList.remove("is-active");
    };
    elapsed < min ? setTimeout(doHide, min - elapsed) : doHide();
  };

  showWithTicket = () => {
    this._shownAt = performance.now();
    this._ticket += 1;
    this._graceUntil = this._shownAt + 60;
    this.overlayTarget.classList.add("is-active");
    return this._ticket;
  };
}
