// app/javascript/controllers/paintproc_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // { "URTH": { surfaces:[…], colors:[…], grains:[…], glosses:[…] }, … }
  static values = { types: Object }

  static targets = [
    "typeSelect",
    "surfaceSelect",
    "colorSelect",
    "grainSelect",
    "glossSelect"
  ]

  connect() {
    // → 各セレクトの <option> を { code:HTMLOptionElement } で保存
    this.optionCache = {
      surface: this.#optionsHash(this.surfaceSelectTarget),
      color:   this.#optionsHash(this.colorSelectTarget),
      grain:   this.#optionsHash(this.grainSelectTarget),
      gloss:   this.#optionsHash(this.glossSelectTarget)
    }
    this.typeChanged()   // 初期反映
  }

  #optionsHash(select) {
    const hash = {}
    Array.from(select.options).forEach(o => { hash[o.value] = o })
    return hash
  }

  // ───────── イベントハンドラ ─────────
  typeChanged() {
    const allow = this.typesValue[this.typeSelectTarget.value] || {}

    this.#apply(this.surfaceSelectTarget, this.optionCache.surface, allow.surfaces)
    this.#apply(this.colorSelectTarget,   this.optionCache.color,   allow.colors)
    this.#apply(this.grainSelectTarget,   this.optionCache.grain,   allow.grains)
    this.#apply(this.glossSelectTarget,   this.optionCache.gloss,   allow.glosses)
  }

  /** allowed 配列だけを option に残し、なければ disabled */
  #apply(select, cache, allowed) {
    // 一旦全 option をクリア
    select.innerHTML = ""

    if (Array.isArray(allowed) && allowed.length > 0) {
      allowed.forEach(code => {
        if (cache[code]) select.append(cache[code])
      })
      select.disabled = false
      select.value = allowed[0]
    } else {
      // 「選択不可」なら NONE 1 個だけ残して disabled
      const noneOpt = document.createElement("option")
      noneOpt.textContent = "—"
      noneOpt.value = ""
      select.append(noneOpt)
      select.disabled = true
      select.value = ""
    }
  }

}
