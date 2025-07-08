import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["dropZone", "partsList", "recipesList", "partsJson", "recipesJson", "item"]

  connect() {
    this.cartParts = []
    this.cartRecipes = []

    // ドロップ側
    Sortable.create(this.dropZoneTarget, {
      group: "carts",
      sort: true,
      animation: 400,
      onAdd: ({ item }) => this.addCart(item)
    })
    // パーツ一覧側
    Sortable.create(this.partsListTarget, {
      group: "carts",
      sort: true,
      animation: 400,
      onAdd: ({ item }) => this.addPartsList(item)
    })
    // レシピ一覧側
    Sortable.create(this.recipesListTarget, {
      group: "carts",
      sort: true,
      animation: 400,
      onAdd: ({ item }) => this.addRecipesList(item)
    })
    this.itemTargets.forEach((el) => {
      this.firstAddCart(el)
    })
  }

  firstAddCart(el) {
    const id   = Number(el.dataset.itemId)
    const type = el.dataset.itemType
    const fs    = el.querySelector("fieldset");
    if (this.dropZoneTarget.contains(el)) {
      const input = el.querySelector(`[data-quantity-for="${id}"]`)
      const qty = input ? parseInt(input.value, 10) : 0
      /* ★ まだ登録されていなければ配列に push */
      if (type == "part") {
        let obj = this.cartParts.find(p => p.part_id === id)
        if (!obj) {
          obj = { part_id: id, qty: qty }
          this.cartParts.push(obj)
        } else {
          obj.qty = qty // すでにあれば更新する
        }
      } else {
        let obj = this.cartRecipes.find(p => p.recipe_id === id)
        if (!obj) {
          obj = { recipe_id: id, qty: qty }
          this.cartRecipes.push(obj)
        } else {
          obj.qty = qty // すでにあれば更新する
        }
      }
      this._updateRemoveIcon(el, id, qty)
      fs.querySelectorAll(".interactive-lock").forEach(lock => {
        lock.disabled = false
      })
      this.updateHidden(type)
    } else {
      this._updateRemoveIcon(el, id, 1)
      this.updateQtyDisplay(el, id, 0)
      fs.querySelectorAll(".interactive-lock").forEach(lock => {
        lock.disabled = true
      })
    }
  }

  addCart(el) {
    const id   = Number(el.dataset.itemId)
    const type = el.dataset.itemType
    let obj;
    if (type == "part") {
      /* ★ まだ登録されていなければ配列に push */
      obj = this.cartParts.find(p => p.part_id === id)
      if (!obj) {
        obj = { part_id: id, qty: 1 }
        this.cartParts.push(obj)
      }
    } else {
      /* ★ まだ登録されていなければ配列に push */
      obj = this.cartRecipes.find(p => p.recipe_id === id)
      if (!obj) {
        obj = { recipe_id: id, qty: 1 }
        this.cartRecipes.push(obj)
      }
    }
    const fs    = el.querySelector("fieldset");
    fs.querySelectorAll(".interactive-lock").forEach(lock => {
      lock.disabled = false
    })
    this.updateQtyDisplay(el, id, obj.qty)
    this.updateHidden(type)
  }

  addPartsList(el) {
    const id   = Number(el.dataset.itemId)
    const type = el.dataset.itemType
    if (type ==="recipe") {
      this.addRecipesList(el)
      this.removeCard(el, this.recipesListTarget)
      return;
    }
    this._updateRemoveIcon(el, id, 1)
    this.updateQtyDisplay(el, id, 0)
    const fs    = el.querySelector("fieldset");
    fs.querySelectorAll(".interactive-lock").forEach(lock => {
      lock.disabled = true
    })
    this.cartParts = this.cartParts.filter(p => p.part_id !== id)
    this.updateHidden(type)
  }

  addRecipesList(el) {
    const id   = Number(el.dataset.itemId)
    const type = el.dataset.itemType
    if (type ==="part") {
      this.addPartsList(el)
      this.removeCard(el, this.partsListTarget)
      return;
    }
    this._updateRemoveIcon(el, id, 1)
    this.updateQtyDisplay(el, id, 0)
    const fs    = el.querySelector("fieldset");
    fs.querySelectorAll(".interactive-lock").forEach(lock => {
      lock.disabled = true
    })
    this.cartRecipes = this.cartRecipes.filter(p => p.recipe_id !== id)
    this.updateHidden(type)
  }

  /* + ボタン */
  increase(event) {
    const el = event.target.closest(".item-card")
    const type = el.dataset.itemType
    if (this.dropZoneTarget.contains(event.currentTarget)) {
      const id  = this.itemId(event)
      const obj = (type ==="part") ?
            this.cartParts.find(p => p.part_id === id) :
            this.cartRecipes.find(p => p.recipe_id === id);
      obj.qty++

      this.updateQtyDisplay(el, id, obj.qty)
      this._updateRemoveIcon(el, id, obj.qty)
      this.updateHidden(type)
    } else {
      this.addCart(el);
      this.dropZoneTarget.append(el);
      el.classList.add("animate-up")
      setTimeout(() => el.classList.remove("animate-up"), 500)
    }
  }

  /* − ボタン */
  decrease(event) {
    const el = event.target.closest(".item-card")
    const type = el.dataset.itemType
    const id  = this.itemId(event)
    const obj = (type === "part") ?
          this.cartParts.find(p => p.part_id === id) :
          this.cartRecipes.find(p => p.recipe_id === id);
    const target = (type === "part") ?
          this.partsListTarget : this.recipesListTarget;

          obj.qty--
    if (obj.qty === 0) {
      type === "part" ? this.addPartsList(el) : this.addRecipesList(el)
      this.removeCard(el, target)
    } else {
      this.updateQtyDisplay(el, id, obj.qty)
      this._updateRemoveIcon(el, id, obj.qty)
    }
    this.updateHidden(type)
  }

  /* 数量 */
  onChangeQty(event){
    const el = event.target.closest(".item-card")
    const id  = this.itemId(event)
    const obj = (type ==="part") ?
          this.cartParts.find(p => p.part_id === id) :
          this.cartRecipes.find(p => p.recipe_id === id);
    const target = (type ==="part") ?
          this.partsListTarget : this.recipesListTarget;
    obj.qty = parseInt(event.target.value, 10)
    if (obj.qty <= 0) {
      obj.qty = 0;
      this.updateQtyDisplay(el, id, obj.qty)
      this.removeCard(el, target)
    } else {
      this._updateRemoveIcon(el, id, obj.qty)
    }
    this.updateHidden(type)
  }

  /* カードを一覧に戻す */
  removeCard(card, target) {
    //const card = e.currentTarget.closest(".item-card")
    //this.addList(card)
    target.append(card)
    card.classList.add("animate-down")
    setTimeout(() => card.classList.remove("animate-down"), 500)
  }

  itemId(e) { return Number(e.currentTarget.parentElement.dataset.itemId) }

  updateQtyDisplay(el, id, qty) {
    el.querySelector(`[data-quantity-for="${id}"]`).value = qty
  }

  updateHidden(type) {
    if (type === "part") {
      console.log("this.hasPartsJsonTarget", this.hasPartsJsonTarget)
      if (!this.hasPartsJsonTarget) return   // 落ちない保険は後で
      this.partsJsonTarget.value = JSON.stringify(this.cartParts)
    } else {
      console.log("this.hasRecipesJsonTarget", this.hasRecipesJsonTarget)
      if (!this.hasRecipesJsonTarget) return   // 落ちない保険は後で
      this.recipesJsonTarget.value = JSON.stringify(this.cartRecipes)
    }
  }

  /* －⇔ごみ箱 アイコン切替 */
  _updateRemoveIcon(el, id, qty) {
    const btn = el.querySelector(`[data-remove-btn-for="${id}"]`)
    if (!btn) return

    if (qty === 1) {
      btn.innerHTML = '<i class="bi bi-trash"></i>'
    } else {
      btn.innerHTML = '<i class="bi bi-dash-lg"></i>'
    }
  }
}