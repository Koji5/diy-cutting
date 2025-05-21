// app/javascript/controllers/service_area_map_controller.js
import { Controller } from "@hotwired/stimulus"
import "leaflet"
import "leaflet-draw"

const L = window.L

export default class extends Controller {
  static values = {
    geojsonPath: String,      // /munis/pref_index.geojson
    initialCodes: Array,
    postUrl: String,
    center: Array,            // [lat, lng] (任意)
    zoom:   Number            // 任意
  }

  #hoverQueue = new Set()
  #hoverTimer = null

  #enqueueHover (layer, style) {
    this.#hoverQueue.add([layer, style])
    if (this.#hoverTimer) return
    this.#hoverTimer = requestAnimationFrame(() => {
      this.#hoverQueue.forEach(([l, s]) => l.setStyle(s))
      this.#hoverQueue.clear()
      this.#hoverTimer = null
    })
  }

  connect () {
    // --- ★1. スタイルをキャッシュ -------------------------------
    this.styles = {
      plain:    { color: "#666",   weight: 1, fillOpacity: 0.1 },
      selected: { color: "#0d6efd", weight: 1, fillOpacity: 0.5 }
    };

    // 1) 内部ステート
    this.selected = new Set(this.initialCodesValue)
    this.loadedPrefs = new Set()               // ★県コードの読込管理
    this.prefLayers   = {}               // ★県ごとの GeoJSON Layer を保持
    this._csrf = document.querySelector("meta[name='csrf-token']").content

    // 2) マップ
    const saved = JSON.parse(localStorage.getItem("coverage.mapview") || "null")
    const lat  = this.centerValue?.[0] ?? saved?.lat ?? 35.7
    const lng  = this.centerValue?.[1] ?? saved?.lng ?? 139.7
    const zoom = this.zoomValue        ?? saved?.zoom ?? 6

    this.map = L.map(this.element).setView([lat, lng], zoom)
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "&copy; OpenStreetMap contributors"
    }).addTo(this.map)

    // viewport 保存
    this.map.on("moveend zoomend", () => this.#storeView())

    // 3) 県境インデックス読み込み
    fetch(this.geojsonPathValue)
      .then(r => r.json())
      .then(json => this.#initPrefIndex(json))
      .catch(e => console.error("pref_index load error:", e))

    // 4) 決定ボタン
    this.#appendDecideButton()
  }

  // ----------------- private -----------------

  #storeView () {
    const c = this.map.getCenter()
    localStorage.setItem("coverage.mapview",
      JSON.stringify({ lat: c.lat, lng: c.lng, zoom: this.map.getZoom() }))
  }

  /** 県境インデックスを地図に載せ、viewport 監視を開始 */
  #initPrefIndex (indexJson) {
    const style = { color: "#aaa", weight: 1, fillOpacity: 0 }

    this.indexLayer = L.geoJSON(indexJson, { style }).addTo(this.map)
    this.#togglePrefLayers()
    this.#loadVisiblePrefs()                 // ★初回に県ロード
    this.map.on("moveend zoomend", () => {
      this.#togglePrefLayers()
      this.#loadVisiblePrefs()
    })
  }
  /** ★ 市区町村レイヤをズームに合わせて add/remove */
  #togglePrefLayers () {
    const show = this.map.getZoom() >= 8
    Object.values(this.prefLayers).forEach(layer => {
      if (show) {
        if (!this.map.hasLayer(layer)) this.map.addLayer(layer)
      } else {
        if (this.map.hasLayer(layer))  this.map.removeLayer(layer)
      }
    })
  }

 /** viewport 内に入った県を判定 → 未ロードだけ fetch (ズーム8以上のみ) */
  #loadVisiblePrefs () {
    if (this.map.getZoom() < 8) return        // ★ズームが浅い時は読まない
    const bounds = this.map.getBounds()
    this.indexLayer.eachLayer(layer => {
      const code = layer.feature.properties.pref_code   // dissolve2 で作った
      if (this.loadedPrefs.has(code)) return
      if (!bounds.intersects(layer.getBounds())) return

      this.loadedPrefs.add(code)
      fetch(`/munis/pref_${code}.geojson`)
        .then(r => r.json())
        .then(json => this.#addCityLayer(json, code))
        .catch(e => console.error(`pref_${code} load error:`, e))
    })
  }

  /** 市区町村レイヤを生成 → prefLayers に保持 */
  #addCityLayer (geojson, prefCode) {
    // --- ★2. styleFn はキャッシュを返すだけ ----------------------
    const styleFn = feat =>
      this.selected.has(feat.properties.N03_007)
        ? this.styles.selected
        : this.styles.plain

    const onEach = (feat, layer) => {
      layer.on("mouseover", () => this.#enqueueHover(layer, { weight: 2 }))
      layer.on("mouseout",  () => this.#enqueueHover(layer, { weight: 1 }))

    layer.on("click", () => {
        const code = feat.properties.N03_007
        if (this.selected.has(code)) {
          this.selected.delete(code)
          layer.setStyle(this.styles.plain)          // ★3 reuse
        } else {
          this.selected.add(code)
          layer.setStyle(this.styles.selected)       // ★3 reuse
        }
      })
    }

    const layer = L.geoJSON(geojson, { style: styleFn, onEachFeature: onEach })
    this.prefLayers[prefCode] = layer
    if (this.map.getZoom() >= 8) this.map.addLayer(layer) // ズーム<8ならとりあえず保持のみ
  }

  #appendDecideButton () {
    const controller = this                      // 参照保持

    const Ctl = L.Control.extend({
      onAdd () {
        const btn = L.DomUtil.create("button", "btn btn-primary")
        btn.innerHTML = '<span class="label">決定</span>'
        btn.style.margin = "8px"

        // すでに saveBtn があればリスナ解除（再生成時の二重バインド防止）
        if (controller.saveBtn) {
          controller.saveBtn.removeEventListener("click", controller._clickFn)
        }

        // ボタンを保持
        controller.saveBtn = btn

        // クリックリスナを登録（押された btn を渡す）
        btn.addEventListener("click", () => controller.#submit(btn))

        return btn
      }
    })

    this.map.addControl(new Ctl({ position: "topright" }))
  }

  /**
   * @param {HTMLButtonElement} btn クリックされたボタン
   */
  #submit (btn) {
    if (btn?.disabled) return           // 二重送信防止
    if (btn) this.#setSaving(btn, true)

    const codes = [...this.selected].filter(Boolean)
    fetch(this.postUrlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this._csrf
      },
      body: JSON.stringify({ city_codes: codes })
    })
      .then(r => r.text())
      .then(html => Turbo.renderStreamMessage(html))
      .catch(err => {
        console.error(err)
        this.#showErrorToast("通信に失敗しました")  // ← サーバーからトーストを取得
      })
      .finally(() => { if (btn) this.#setSaving(btn, false) })
  }

  #setSaving (btn, flag) {
    btn.disabled = flag
    const label = btn.querySelector(".label") || btn   // label span が無い場合にも対応
    if (flag) {
      label.innerHTML = '<span class="spinner-border spinner-border-sm" role="status"></span> 保存中'
    } else {
      label.textContent = "決定"
    }
  }

  /** サーバー側 partial を Turbo Stream で受け取り、そのまま流し込む */
  #showErrorToast (msg) {
    fetch(
      `/vendors/flash_toast?` +
      new URLSearchParams({ msg, type: "danger" })
    )
      .then(r => r.text())
      .then(html => Turbo.renderStreamMessage(html))
      .catch(e => console.error("toast fetch error:", e))
  }
}
