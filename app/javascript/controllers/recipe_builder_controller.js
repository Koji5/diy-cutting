import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["dropZone", "partsList", "hidden"]

  connect() {
    this.recipeParts = []
    // ドロップ側
    Sortable.create(this.dropZoneTarget, {
      group: "parts",
      animation: 150,
      onAdd: ({ item }) => this.addPart(item)
    })
    // 一覧側（カードを戻せるように group を合わせる）
    Sortable.create(this.partsListTarget, {
      group: "parts",
      sort: false,
      onAdd: ({ item }) => this.addList(item)
    })
  }

  /* ドロップ後に数量 UI 付きカードへ置換 */
  addPart(el) {
    const id   = Number(el.dataset.partId)

    /* ★ まだ登録されていなければ配列に push */
    let obj = this.recipeParts.find(p => p.part_id === id)
    if (!obj) {
      obj = { part_id: id, qty: 1 }
      this.recipeParts.push(obj)
    }
    const fs    = el.querySelector("fieldset");
    fs.disabled = false;
    this.updateQtyDisplay(id, obj.qty)
    this.updateHidden()
  }

  addList(el) {
    const id   = Number(el.dataset.partId)

    this._updateRemoveIcon(id, 1)
    this.updateQtyDisplay(id, 0)
    const fs    = el.querySelector("fieldset");
    fs.disabled = true;

    this.partsListTarget.prepend(el)
    this.recipeParts = this.recipeParts.filter(p => p.part_id !== id)
    this.updateHidden()
  }

  /* + ボタン */
  increase(event) {
    const id  = this.partId(event)
    const obj = this.recipeParts.find(p => p.part_id === id)
    obj.qty++

    this.updateQtyDisplay(id, obj.qty)
    this._updateRemoveIcon(id, obj.qty)
    this.updateHidden()
  }

  /* − ボタン */
  decrease(event) {
    const id  = this.partId(event)
    const obj = this.recipeParts.find(p => p.part_id === id)
    obj.qty--

    if (obj.qty === 0) {
      this.removeCard(id, event)
    } else {
      this.updateQtyDisplay(id, obj.qty)
      this._updateRemoveIcon(id, obj.qty)
    }
    this.updateHidden()
  }

  /* カードを一覧に戻す */
  removeCard(id, e) {
    const card = e.currentTarget.closest(".part-card")
    this.addList(card)
  }

  partId(e) { return Number(e.currentTarget.parentElement.dataset.partId) }

  updateQtyDisplay(id, qty) {
    this.element.querySelector(`[data-quantity-for="${id}"]`).value = qty
  }

  updateHidden() {
    console.log("updateHidden", this.hasHiddenTarget, this.hiddenTarget)
    if (!this.hasHiddenTarget) return   // 落ちない保険は後で
    this.hiddenTarget.value = JSON.stringify(this.recipeParts)
  }

  /* －⇔ごみ箱 アイコン切替 */
  _updateRemoveIcon(id, qty) {
    const btn = this.element.querySelector(`[data-remove-btn-for="${id}"]`)
    if (!btn) return

    if (qty === 1) {
      btn.innerHTML = '<i class="bi bi-trash"></i>'
    } else {
      btn.innerHTML = '<i class="bi bi-dash-lg"></i>'
    }
  }
}
