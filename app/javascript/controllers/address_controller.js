// app/javascript/controllers/address_controller.js
import { Controller } from "@hotwired/stimulus"

/*
  Targets
  -------
  zip        : 郵便番号入力
  zipBtn     : 検索ボタン
  pref       : 都道府県 <select>
  city       : 市区町村 <select>
  addr1      : 町域以降 <input text>
  modal      : Bootstrap モーダル本体
  modalBody  : モーダルの中身を差し替える領域
*/
export default class extends Controller {
  static targets = [
    "zip", "zipBtn",
    "pref", "city",
    "addr1",
    "modal", "modalBody"
  ]

  // --------------------------------------------------
  // ライフサイクル
  // --------------------------------------------------
  connect () {
    // Bootstrap モーダルを初期化
    this.bsModal = new bootstrap.Modal(this.modalTarget)
  }

  // --------------------------------------------------
  // 郵便番号検索
  // --------------------------------------------------
  async searchZip () {
    const zip = this.zipTarget.value.replace(/\D/g, "")

    if (zip.length !== 7) {
      alert("郵便番号は 7 桁の数字で入力してください")
      return
    }

    const loader = document.getElementById("nowloading")
    loader?.classList.add("is-active")

    const res  = await fetch(`/postal_lookup/${zip}`)
    const data = await res.json()

    this.populateCityOptions(data.cities)

    if (data.addresses.length === 0) {
      loader?.classList.remove("is-active")
      alert("該当する住所が見つかりません")
    } else if (data.addresses.length === 1) {
      this.applyAddress(data.addresses[0])
    } else {
      this.renderModal(data.addresses)
      this.bsModal.show()
    }
    loader?.classList.remove("is-active")
  }

  // --------------------------------------------------
  // 都道府県変更 → 市区町村を Ajax でロード
  // --------------------------------------------------
  async loadCities(eventOrCity = null) {
    const prefCode = this.prefTarget.value
    if (!prefCode) {
      this.populateCityOptions([])
      this.cityTarget.value = ""
      return
    }
    const loader = document.getElementById("nowloading")
    loader?.classList.add("is-active")

    const res  = await fetch(`/prefectures/${prefCode}/cities`)
    const list = await res.json()

    this.populateCityOptions(list)
    this.cityTarget.value = ""

    loader?.classList.remove("is-active")
  }

  // --------------------------------------------------
  // private helpers
  // --------------------------------------------------
  /** 住所フォームへ反映 */
  applyAddress (row) {
    // --- 都道府県 & 市区町村 ---------------------------------
    this.prefTarget.value = row.city_code.slice(0, 2)  // 先頭 2 桁
    this.cityTarget.value = row.city_code
    // --- 町域以降 --------------------------------------------
    this.addr1Target.value = row.town_area_name_kanji || ""
  }

  /** 候補リストをモーダルに描画（クリック即確定方式） */
  renderModal (list) {
    const html = list.map(r => `
      <button type="button"
              class="list-group-item list-group-item-action d-flex align-items-center gap-2"
              data-action="click->address#choose"
              data-address-row='${JSON.stringify(r)}'>
        <span class="badge bg-primary rounded-pill">選択</span>
        <span>${r.city_town_name_kanji}${r.town_area_name_kanji || ""}</span>
      </button>
    `).join("")

    this.modalBodyTarget.innerHTML = `
      <div class="list-group">${html}</div>
      <p class="text-muted small mt-2 mb-0">
        ボタンをクリックすると住所に反映されます
      </p>
    `
  }

  /** モーダル内候補クリック → フォームへ反映 */
  choose (event) {
    const row = JSON.parse(event.currentTarget.dataset.addressRow)
    this.applyAddress(row)
    this.bsModal.hide()
  }

  populateCityOptions(cities) {
    this.cityTarget.innerHTML =
      '<option value=\"\">-- 市区町村 --</option>' +
      cities.map(c =>
        `<option value=\"${c.code}\">${c.name_ja}</option>`
      ).join("")
  }
}
