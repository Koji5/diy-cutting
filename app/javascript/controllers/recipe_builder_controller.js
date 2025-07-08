import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["dropZone", "partsList", "hidden", "item"]

  connect() {
    this.recipeParts = []
    // ドロップ側
    Sortable.create(this.dropZoneTarget, {
      group: "parts",
      sort: true,
      animation: 400,
      onAdd: ({ item }) => this.addPart(item)
    })
    // 一覧側（カードを戻せるように group を合わせる）
    Sortable.create(this.partsListTarget, {
      group: "parts",
      sort: true,
      animation: 400,
      onAdd: ({ item }) => this.addList(item)
    })
    this.itemTargets.forEach((el) => {
      this.firstAddPart(el)
    })
  }

  firstAddPart(el) {
    const id   = Number(el.dataset.partId)
    const fs    = el.querySelector("fieldset");
    if (this.dropZoneTarget.contains(el)) {
      const input = el.querySelector(`[data-quantity-for="${id}"]`)
      const qty = input ? parseInt(input.value, 10) : 0
      /* ★ まだ登録されていなければ配列に push */
      let obj = this.recipeParts.find(p => p.part_id === id)
      if (!obj) {
        obj = { part_id: id, qty: qty }
        this.recipeParts.push(obj)
      } else {
        obj.qty = qty // すでにあれば更新する
      }
      this._updateRemoveIcon(id, qty)
      fs.querySelectorAll(".interactive-lock").forEach(lock => {
        lock.disabled = false
      })
      this.updateHidden()
    } else {
      this._updateRemoveIcon(id, 1)
      this.updateQtyDisplay(id, 0)
      fs.querySelectorAll(".interactive-lock").forEach(lock => {
        lock.disabled = true
      })
    }
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
    fs.querySelectorAll(".interactive-lock").forEach(lock => {
      lock.disabled = false
    })
    this.updateQtyDisplay(id, obj.qty)
    this.updateHidden()
  }

  addList(el) {
    const id   = Number(el.dataset.partId)

    this._updateRemoveIcon(id, 1)
    this.updateQtyDisplay(id, 0)
    const fs    = el.querySelector("fieldset");
    fs.querySelectorAll(".interactive-lock").forEach(lock => {
      lock.disabled = true
    })

    this.recipeParts = this.recipeParts.filter(p => p.part_id !== id)
    
    this.updateHidden()
  }

  /* + ボタン */
  increase(event) {
    if (this.dropZoneTarget.contains(event.currentTarget)) {
      const id  = this.partId(event)
      const obj = this.recipeParts.find(p => p.part_id === id)
      obj.qty++

      this.updateQtyDisplay(id, obj.qty)
      this._updateRemoveIcon(id, obj.qty)
      this.updateHidden()
    } else {
      const card = event.target.closest(".part-card")
      this.addPart(card);
      this.dropZoneTarget.append(card);
      card.classList.add("animate-up")
      setTimeout(() => card.classList.remove("animate-up"), 500)
    }
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

  /* 数量 */
  onChangeQty(event){
    const id  = this.partId(event)
    const obj = this.recipeParts.find(p => p.part_id === id)
    obj.qty = parseInt(event.target.value, 10)
    if (obj.qty <= 0) {
      obj.qty = 0;
      this.updateQtyDisplay(id, obj.qty)
      this.removeCard(id, event)
    } else {
      this._updateRemoveIcon(id, obj.qty)
    }
    this.updateHidden()
  }

  /* カードを一覧に戻す */
  removeCard(id, e) {
    const card = e.currentTarget.closest(".part-card")
    this.addList(card)
    this.partsListTarget.append(card)
    card.classList.add("animate-down")
    setTimeout(() => card.classList.remove("animate-down"), 500)
  }

  partId(e) { return Number(e.currentTarget.parentElement.dataset.partId) }

  updateQtyDisplay(id, qty) {
    this.element.querySelector(`[data-quantity-for="${id}"]`).value = qty
  }

  updateHidden() {
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
