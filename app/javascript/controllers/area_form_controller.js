// app/javascript/controllers/area_form_controller.js
import { Controller } from "@hotwired/stimulus"

const L = window.L

export default class extends Controller {
  static targets = ["payload", "serviceAreaMap", "prefCityMap", "allCityCodes"]
  static values = {
    geojsonPath: String,
    initialCodes: Array,
    postUrl: String
  }

  connect() {
    this.selectedCities = new Set(this.initialCodesValue)
    this.prefCityMap = JSON.parse(this.prefCityMapTarget.value)
    this.allCityCodes = JSON.parse(this.allCityCodesTarget.value)

    if (this.map) return
    this.map = this.#initMap()
    this.#loadNationalLayer()
    this.#loadPrefIndex()
  }

  #initMap() {
    const map = L.map(this.serviceAreaMapTarget)
    map.fitBounds([[26, 126], [45, 148]])
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "&copy; OpenStreetMap contributors"
    }).addTo(map)

    map.on("zoomend", () => {
      this.#toggleLayers()
    })

    map.on("moveend", () => {
      this.#loadVisiblePrefs()
    })

    return map
  }

  async #loadNationalLayer() {
    const res = await fetch("/munis/national.geojson")
    const geojson = await res.json()

    const layer = L.geoJSON(geojson, {
      style: this.#nationalStyle.bind(this),
      onEachFeature: this.#onEachNational.bind(this)
    })

    this.nationalLayer = layer
    this.map.addLayer(layer)
  }

  async #loadPrefIndex() {
    const res = await fetch(this.geojsonPathValue)
    const data = await res.json()

    this.indexLayer = L.geoJSON(data, {
      style: this.#prefStyle.bind(this),
      onEachFeature: this.#onEachPref.bind(this)
    })

    this.map.addLayer(this.indexLayer)
    this.#toggleLayers()
    this.#loadVisiblePrefs()
  }

  #toggleLayers() {
    const zoom = this.map.getZoom()

    if (this.nationalLayer) {
      this.map[zoom <= 5 ? "addLayer" : "removeLayer"](this.nationalLayer)
    }

    if (this.indexLayer) {
      this.map[zoom >= 6 ? "addLayer" : "removeLayer"](this.indexLayer)
      if (this.map.hasLayer(this.indexLayer)) {
        this.indexLayer.setStyle(this.#prefStyle.bind(this))
      }
    }

    const showCities = zoom >= 9
    const bounds = this.map.getBounds()

    Object.entries(this.prefLayers || {}).forEach(([prefCode, layer]) => {
      const shouldShow = showCities && bounds.intersects(layer.getBounds())
      const hasLayer = this.map.hasLayer(layer)
      if (shouldShow && !hasLayer) {
        this.map.addLayer(layer)
      } else if (!shouldShow && hasLayer) {
        this.map.removeLayer(layer)
      }
    })
  }

  async #loadCityLayer(prefCode) {
    const res = await fetch(`/munis/pref_${prefCode}.geojson`)
    const geojson = await res.json()

    const styleFn = feat => {
      const code = feat.properties.N03_007
      return this.selectedCities.has(code)
        ? { color: "#0d6efd", weight: 1, fillOpacity: 0.5 }
        : { color: "#666", weight: 1, fillOpacity: 0 }
    }

    const onEach = (feat, layer) => {
      const code = feat.properties.N03_007
      layer.on("click", () => {
        if (this.selectedCities.has(code)) {
          this.selectedCities.delete(code)
        } else {
          this.selectedCities.add(code)
        }
        layer.setStyle(styleFn(feat))
        this.#updatePayload()
      })
    }

    const layer = L.geoJSON(geojson, { style: styleFn, onEachFeature: onEach })
    this.prefLayers ||= {}
    this.prefLayers[prefCode] = layer
    if (this.map.getZoom() >= 9 && this.map.getBounds().intersects(layer.getBounds())) {
      this.map.addLayer(layer)
    }
  }

  #loadVisiblePrefs() {
    if (this.map.getZoom() < 9 || !this.indexLayer) return
    const bounds = this.map.getBounds()

    this.indexLayer.eachLayer(layer => {
      const prefCode = layer.feature.properties.pref_code
      if (this.prefLayers?.[prefCode]) return
      if (!bounds.intersects(layer.getBounds())) return
      this.#loadCityLayer(prefCode)
    })
  }

  #onEachNational(feature, layer) {
    layer.on("click", () => {
      const allSelected = this.allCityCodes.every(code => this.selectedCities.has(code))
      if (allSelected) {
        this.allCityCodes.forEach(code => this.selectedCities.delete(code))
      } else {
        this.allCityCodes.forEach(code => this.selectedCities.add(code))
      }
      this.#updatePayload()
      layer.setStyle(this.#nationalStyle(feature))
    })
  }

  #onEachPref(feature, layer) {
    const prefCode = feature.properties.pref_code
    layer.on("click", () => {
      const cityCodes = this.prefCityMap[prefCode] || []
      const allSelected = cityCodes.every(code => this.selectedCities.has(code))

      if (allSelected) {
        cityCodes.forEach(code => this.selectedCities.delete(code))
      } else {
        cityCodes.forEach(code => this.selectedCities.add(code))
      }
      this.#updatePayload()
      layer.setStyle(this.#prefStyle(feature))
    })
  }

  #nationalStyle(feature) {
    const selectedCount = this.allCityCodes.filter(code => this.selectedCities.has(code)).length

    if (selectedCount === this.allCityCodes.length && selectedCount > 0) {
      return { color: "#0d6efd", weight: 1, fillOpacity: 0.5 }
    } else if (selectedCount > 0) {
      return { color: "#0d6efd", weight: 1, fillOpacity: 0.3 }
    } else {
      return { weight: 1, fillOpacity: 0 }
    }
  }

  #prefStyle(feature) {
    const zoom = this.map.getZoom()
    const prefCode = feature.properties.pref_code
    const cities = this.prefCityMap[prefCode] || []
    const selectedCount = cities.filter(code => this.selectedCities.has(code)).length
    let weight
    let fillOpacity = 1

    if (zoom <= 7) {
      weight = 1
    } else if (zoom === 8) {
      weight = 2
    } else {
      weight = 3
      fillOpacity = 0
    }

    if (selectedCount === cities.length && selectedCount > 0) {
      return { color: "#0d6efd", weight, fillOpacity: 0.5 * fillOpacity }
    } else if (selectedCount > 0) {
      return { color: "#0d6efd", weight, fillOpacity: 0.3 * fillOpacity }
    } else {
      return { color: "#0d6efd", weight, fillOpacity: 0 }
    }
  }

  #updatePayload() {
    this.payloadTarget.value = JSON.stringify({
      city_codes: [...this.selectedCities]
    })

    if (this.indexLayer) this.indexLayer.setStyle(this.#prefStyle.bind(this))
    if (this.nationalLayer) this.nationalLayer.setStyle(this.#nationalStyle.bind(this))
    Object.values(this.prefLayers || {}).forEach(layer => {
      layer.setStyle(layer.options.style)
    })
  }
}
