// app/javascript/controllers/copy_address_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { source: String, target: String }

  copy() {
    // -------- 1. city_code を保持 --------------------------
    const cityCode = this._field("city_code").src?.value || ""

    // -------- 2. 先に他フィールドをコピー ------------------
    const fields = [
      "postal_code",
      "prefecture_code",   // ← ★ これを必ずコピー
      "address_line",
      "department",
      "phone_number"
    ]
    fields.forEach((f) => this.copyField(f))

    // -------- 3. 都道府県 change を発火 ---------------------
    const destPref = this._field("prefecture_code").dst
    if (destPref) {
      // address controller 要素に cityCode を一時保存
      const adrElm = destPref.closest("[data-controller~='address']")
      if (adrElm) adrElm.dataset.cityCode = cityCode

      // change 発火 → address#loadCities が実行される
      destPref.dispatchEvent(new Event("change", { bubbles: true }))
    }
  }

  _field(name) {
    return {
      src: this.element.querySelector(`[name$='[${this.sourceValue}_${name}]']`),
      dst: this.element.querySelector(`[name$='[${this.targetValue}_${name}]']`)
    }
  }
  // ---------------- private ---------------
  findField(prefix, field) {
    return this.element.querySelector(`[name$='[${prefix}_${field}]']`)
  }

  copyField(field) {
    const src  = this.findField(this.sourceValue, field)
    const dest = this.findField(this.targetValue, field)
    if (src && dest) {
      dest.value = src.value
      dest.dispatchEvent(new Event("input", { bubbles: true }))
    }
  }
}
