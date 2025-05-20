import { Controller } from "@hotwired/stimulus"
import "leaflet"
import "leaflet-draw"
const L = window.L 

export default class extends Controller {
  static values = {
    // すでに選択済みの city_code 配列 JSON
    initialCodes: Array,
    // GeoJSON 取得先（都道府県単位のファイルでも全国ファイルでも可）
    geojsonPath: String,
    // Bulk POST 先 URL
    postUrl: String
  }

  connect() {
    // ---- 1. 内部 State 初期化 ----
    this.selected = new Set(this.initialCodesValue) // 既存選択
    this._csrfToken = document.querySelector("meta[name='csrf-token']").content

    // ---- 2. Leaflet マップ生成 ----
    this.map = L.map(this.element).setView([35.7, 139.7], 6)
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "&copy; OpenStreetMap contributors"
    }).addTo(this.map)

    // ---- 3. GeoJSON 読み込みしレイヤ追加 ----
    fetch(this.geojsonPathValue)
      .then(r => r.json())
      .then(json => this.#addGeoJSON(json))
      .catch(err => console.error("GeoJSON load error:", err))

    // ---- 4. 決定ボタン生成 ----
    this.#appendDecideButton()
  }

  // ------- private methods -------

  #addGeoJSON(geojson) {
    const styleFn = feat => {
      // ★ city_code → code → N03_007 の順で存在するものを使う
      const code = feat.properties.city_code || feat.properties.code || feat.properties.N03_007

      return {
        color:       this.selected.has(code) ? "#0d6efd" : "#666",
        weight:      1,
        fillOpacity: this.selected.has(code) ? 0.5       : 0.1
      }
    }

    const onEach = (feat, layer) => {
      // Hover: ハイライト
      layer.on("mouseover", () => layer.setStyle({ weight: 2 }))
      layer.on("mouseout",  () => layer.setStyle({ weight: 1 }))

      // Click: 選択トグル
      layer.on("click", () => this.#toggleSelection(feat, layer))
    }

    this.layerGroup = L.geoJSON(geojson, { style: styleFn, onEachFeature: onEach })
    this.layerGroup.addTo(this.map)
    this.map.fitBounds(this.layerGroup.getBounds())
  }

  #toggleSelection(feature, layer) {
    const code = feature.properties.city_code ||    // N03 標準
                 feature.properties.code      ||    // サンプル
                 feature.properties.N03_007         // まれにこのキー
    if (this.selected.has(code)) {
      this.selected.delete(code)
      layer.setStyle({ color: "#666", fillOpacity: 0.1 })
    } else {
      this.selected.add(code)
      layer.setStyle({ color: "#0d6efd", fillOpacity: 0.5 })
    }
  }

  #appendDecideButton() {
    // Leaflet の Control として右上にボタンを設置
    const Decide = L.Control.extend({
      onAdd: () => {
        const btn = L.DomUtil.create("button", "btn btn-primary")
        btn.textContent = "決定"
        btn.style.margin = "8px"
        btn.onclick = () => this.#submit()
        return btn
      }
    })
    this.map.addControl(new Decide({ position: "topright" }))
  }

  #submit() {
    const codes = Array.from(this.selected).filter(Boolean)
    if (codes.length === 0) return alert("市区町村を選択してください")

    fetch(this.postUrlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this._csrfToken,
        "Accept": "text/vnd.turbo-stream.html"      // ★ Turbo-Stream で受け取る
      },
      body: JSON.stringify({ city_codes: codes })
    })
      .then(resp => {
        if (!resp.ok) throw new Error(resp.statusText) // ★ エラー判定はここで
        return resp.text()                             // ★ OKなら本文を返す
      })
      .then(html => Turbo.renderStreamMessage(html))   // ★ トーストを描画
      .catch(err => {
        console.error("Save error:", err)
        alert("保存に失敗しました")
      })
  }

}
