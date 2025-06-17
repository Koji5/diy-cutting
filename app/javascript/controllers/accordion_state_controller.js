// app/javascript/controllers/accordion_state_controller.js
import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  // accordion コンテナ (<div class="accordion">) に付ける
  static values  = { id: String }               // 必須: 一意キー
  static targets = ["collapse"]                 // 各 .collapse 要素

  connect () {
    if (!this.hasIdValue) return

    /* ---------- ① 状態を即時復元（非アニメーション） ---------- */
    const openIds = this._load()                // ["pane1","pane3", ...]
    this.collapseTargets.forEach(el => {
      el.classList.toggle("show", openIds.includes(el.id))
    })

    /* ---------- ② Collapse を生成（toggle:false で静かに） ----- */
    this.collapseTargets.forEach(el => {
      const inst = bootstrap.Collapse.getOrCreateInstance(el, { toggle: false })

      // ユーザ操作に合わせて保存
      el.addEventListener("shown.bs.collapse",  () => this._save())
      el.addEventListener("hidden.bs.collapse", () => this._save())
    })
  }

  /* ---- 状態保存（開いている pane の id を配列で保持） --------- */
  _save () {
    const openIds = this.collapseTargets
      .filter(el => el.classList.contains("show"))
      .map(el => el.id)

    localStorage.setItem(this._key(), JSON.stringify(openIds))
  }

  /* ---- 状態読込 ------------------------------------------------- */
  _load () {
    try {
      return JSON.parse(localStorage.getItem(this._key()) || "[]")
    } catch { return [] }
  }

  _key () {                  // 例: accordionState:dashboard-sidebar
    return `accordionState:${this.idValue}`
  }
}
