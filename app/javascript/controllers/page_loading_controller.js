import { Controller } from "@hotwired/stimulus"

/*
  Shows an overlay (target: overlay) while Turbo navigation / requests are in flight.
  - Adds .is-active on show(), removes on hide()
  - Keeps an internal Set of pending Promises so you can call `register(promise)` from
    other controllers / fetches and have the overlay automatically disappear when all
    are resolved.
*/
export default class extends Controller {
  static targets = ["overlay"]
  pending = new Set()

  connect () {
    /* ---------------- Turbo navigation / request ---------------- */
    addEventListener("turbo:before-visit",            () => this.show())
    addEventListener("turbo:before-fetch-request",    (e) => {
      const headers = e.detail.fetchOptions.headers || {}
      const isPrefetch = headers["Purpose"]       === "prefetch" ||
                         headers["Sec-Purpose"]   === "prefetch" ||
                         headers["X-Sec-Purpose"] === "prefetch"
      if (!isPrefetch) this.show()
    })

    /* Frame・Full reload both trigger turbo:render */
    addEventListener("turbo:render",  (e) => {
      // Skip preview (bfcache) renders
      if (document.documentElement.hasAttribute("data-turbo-preview")) return
      this.show()           // hand‑off CSS overlay → JS overlay
      requestAnimationFrame(() => { if (this.pending.size === 0) this.hide() })
    })

    addEventListener("page-render:done", () => {
      this.hide() // ← loading オーバーレイを消すなど
    })

    /* NEW — hide after *any* frame or full load completes */
    addEventListener("turbo:frame-load", () => this.hide())
    addEventListener("turbo:load",       () => this.hide())

    /* Error responses (422/500 etc.) */
    addEventListener("turbo:before-fetch-response", (e) => {
      if (e.detail.fetchResponse.response.status >= 400) this.hide()
    })

    /* Promise completion hook */
    addEventListener("page-loading:done", ({ detail: promise }) => {
      this.pending.delete(promise)
      if (this.pending.size === 0) this.hide()
    })
  }

  /* Register an external promise to keep the overlay visible */
  register (promise) {
    this.pending.add(promise)
    promise.finally(() =>
      dispatchEvent(new CustomEvent("page-loading:done", { detail: promise }))
    )
  }

  show () { this.overlayTarget.classList.add("is-active") }
  hide () { this.overlayTarget.classList.remove("is-active") }
}
