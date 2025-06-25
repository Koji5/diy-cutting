import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// SortableJS を Importmap でピン留めしておく
// pin "sortablejs", to: "https://cdn.jsdelivr.net/npm/sortablejs@1.15.6/+esm"

export default class extends Controller {
  static targets = ["dropZone", "partsList", "hidden"]

  initialize() {
    console.log("init", this.hasHiddenTarget)
  }

  connect() {
    console.log("connect", this.hasHiddenTarget, this.hiddenTarget)
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
      sort: false
    })
  }

  disconnect() {
    console.log("disconnect")
  }

  listTemplate(name, thumbUrl) {
    return `
      <img src="${thumbUrl}" width="48" height="48"
          class="rounded me-2 flex-shrink-0 object-fit-cover" alt="">
      <span>${name}</span>
    `
  }

  /* ドロップ後に数量 UI 付きカードへ置換 */
  addPart(el) {
    const id   = Number(el.dataset.partId)
    const name = el.dataset.partName
    const thumbUrl = el.dataset.thumbUrl

    /* ★ まだ登録されていなければ配列に push */
    let obj = this.recipeParts.find(p => p.part_id === id)
    if (!obj) {
      obj = { part_id: id, qty: 1 }
      this.recipeParts.push(obj)
    }

    el.innerHTML = this.cardTemplate(id, name, obj.qty, thumbUrl)
    this.updateHidden()
  }

  /* + ボタン */
  increase(event) {
    const id  = this.partId(event)
    const obj = this.recipeParts.find(p => p.part_id === id)
    obj.qty++

    this.updateQtyDisplay(id, obj.qty)
    this._updateRemoveIcon(id, obj.qty)     // ← 追加
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
      this._updateRemoveIcon(id, obj.qty)   // ← 追加
    }
    this.updateHidden()
  }

  /* カードを一覧に戻す */
  removeCard(id, e) {
    const card = e.currentTarget.closest(".part-card")
    card.innerHTML = this.listTemplate(
                      card.dataset.partName,
                      card.dataset.thumbUrl
                    )
    this.partsListTarget.prepend(card)
    this.recipeParts = this.recipeParts.filter(p => p.part_id !== id)
  }

  /* ------------------ util ------------------ */
  cardTemplate(id, name, qty, thumbUrl) {
    const minusHtml  = '<i class="bi bi-dash-lg"></i>'   // －アイコン
    const trashHtml  = '<i class="bi bi-trash"></i>'     // ごみ箱アイコン
    const removeIcon = (qty === 1) ? trashHtml : minusHtml
    return `
      <img src="${thumbUrl}" width="32" height="32"
         class="rounded me-2 flex-shrink-0 object-fit-cover" alt="">

      <span class="flex-grow-1">${name}</span>

      <div class="btn-group btn-group-sm" role="group" data-part-id="${id}">
        <button type="button"
                class="btn btn-outline-secondary"
                data-turbo="false"
                data-action="click->recipe-builder#decrease"
                data-remove-btn-for="${id}">
          ${removeIcon}
        </button>

        <span class="px-2 fw-bold"
              data-quantity-for="${id}">${qty}</span>

        <button type="button"
                class="btn btn-outline-secondary"
                data-turbo="false"
                data-action="click->recipe-builder#increase">＋</button>
      </div>`
  }

  partId(e) { return Number(e.currentTarget.parentElement.dataset.partId) }

  updateQtyDisplay(id, qty) {
    this.element.querySelector(`[data-quantity-for="${id}"]`).textContent = qty
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
