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

  connect() {
    /* --- Turbo navigation / request start --- */
    addEventListener("turbo:before-visit", () => this.show())
    addEventListener("turbo:before-fetch-request", (e) => {
      const headers = e.detail.fetchOptions.headers || {}
      const isPrefetch =
        headers["Purpose"] === "prefetch" ||
        headers["Sec-Purpose"] === "prefetch" ||
        headers["X-Sec-Purpose"] === "prefetch"
      if (!isPrefetch) this.show()
    })

    /* --- Turbo render complete --- */
    addEventListener("turbo:render", (e) => {
      if (document.documentElement.hasAttribute("data-turbo-preview")) return
      this.show()
      requestAnimationFrame(() => {
        if (!this.preventHide && this.pending.size === 0) this.hide()
      })
    })

    /* --- Completed events --- */
    addEventListener("turbo:frame-load", () => {
      if (!this.preventHide) this.hide()
    })

    addEventListener("turbo:load", () => {
      if (!this.preventHide) this.hide()
    })

    addEventListener("page-render:done", () => {
      if (!this.preventHide) this.hide()
    })

    addEventListener("turbo:before-fetch-response", (e) => {
      if (e.detail.fetchResponse.response.status >= 400) {
        if (!this.preventHide) this.hide()
      }
    })

    /* --- Custom Promise tracker --- */
    addEventListener("page-loading:done", ({ detail: promise }) => {
      this.pending.delete(promise)
      if (!this.preventHide && this.pending.size === 0) {
        this.hide()
      }
    })
  }

  /**
   * Register an external Promise.
   * The overlay will stay visible until the Promise resolves or rejects.
   */
  register(promise) {
    this.pending.add(promise)
    promise.finally(() => {
      dispatchEvent(new CustomEvent("page-loading:done", { detail: promise }))
    })
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
    this.overlayTarget.classList.add("is-active")
  }

  hide() {
    this.overlayTarget.classList.remove("is-active")
  }
}
