import { Controller } from "@hotwired/stimulus"

const L = window.L

export default class extends Controller {
  static targets = [
    "payload", "serviceAreaMap"
  ]

  static values = {
    geojsonPath: String,
    initialCodes: Array,
    postUrl: String
  }

  connect() {
    this.selected = new Set(this.initialCodesValue)
    this.prefLayers = {}
    this.loadedPrefs = new Set()
    if (this.map) return
    this.map = this.#initMap()

    this.#loadPrefIndex()
  }

  // 地図初期化
  #initMap() {
    const map = L.map(this.serviceAreaMapTarget).setView([35.7, 139.7], 6)
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "&copy; OpenStreetMap contributors"
    }).addTo(map)

    map.on("moveend zoomend", () => {
      this.#togglePrefLayers()
      this.#loadVisiblePrefs()
    })

    return map
  }

  // 都道府県インデックス読み込み（pref_index.geojson）
  async #loadPrefIndex() {
    const res = await fetch(this.geojsonPathValue)
    const data = await res.json()

    const style = { color: "#aaa", weight: 1, fillOpacity: 0 }
    this.indexLayer = L.geoJSON(data, { style }).addTo(this.map)

    this.#togglePrefLayers()
    this.#loadVisiblePrefs()
  }

  // ズームによって pref_xx.geojson レイヤを表示/非表示
  #togglePrefLayers() {
    const show = this.map.getZoom() >= 8
    Object.values(this.prefLayers).forEach(layer => {
      if (show) {
        if (!this.map.hasLayer(layer)) this.map.addLayer(layer)
      } else {
        if (this.map.hasLayer(layer)) this.map.removeLayer(layer)
      }
    })
  }

  // viewport に入った県の市区町村レイヤ(pref_xx.geojson)を読み込む
  #loadVisiblePrefs() {
    if (this.map.getZoom() < 8) return
    const bounds = this.map.getBounds()

    this.indexLayer.eachLayer(layer => {
      const prefCode = layer.feature.properties.pref_code
      if (this.loadedPrefs.has(prefCode)) return
      if (!bounds.intersects(layer.getBounds())) return

      this.loadedPrefs.add(prefCode)
      this.#loadCityLayer(prefCode)
    })
  }

  // pref_xx.geojson 読み込み
  async #loadCityLayer(prefCode) {
    const res = await fetch(`/munis/pref_${prefCode}.geojson`)
    const geojson = await res.json()

    const styleFn = feat => {
      const code = feat.properties.N03_007
      return this.selected.has(code)
        ? { color: "#0d6efd", weight: 1, fillOpacity: 0.5 }
        : { color: "#666", weight: 1, fillOpacity: 0.1 }
    }

    const onEach = (feat, layer) => {
      const code = feat.properties.N03_007
      layer.on("click", () => {
        if (this.selected.has(code)) {
          this.selected.delete(code)
        } else {
          this.selected.add(code)
        }
        layer.setStyle(styleFn(feat))
        this.#updatePayload()
      })
    }

    const layer = L.geoJSON(geojson, { style: styleFn, onEachFeature: onEach })
    this.prefLayers[prefCode] = layer
    if (this.map.getZoom() >= 8) this.map.addLayer(layer)
  }

  // 選択された市区町村コードを hidden に書き込む
  #updatePayload() {
    this.payloadTarget.value = JSON.stringify({
      city_codes: [...this.selected]
    })
  }

}
