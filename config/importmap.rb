pin "application"                       # ← to: 省略
pin "@popperjs/core", to: "@popperjs--core.js"
pin "bootstrap",        to: "bootstrap.bundle.min.js"
pin "@hotwired/stimulus",        to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@hotwired/turbo-rails",      to: "turbo.min.js", preload: true

pin "controllers",                to: "controllers/index.js"
pin_all_from "app/javascript/controllers", under: "controllers"

pin "leaflet",       to: "https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
pin "leaflet-draw",  to: "https://unpkg.com/leaflet-draw@1.0.4/dist/leaflet.draw.js"

pin "controllers/coverage_selector_controller", to: "controllers/coverage_selector_controller.js"
pin "controllers/service_area_map_controller",  to: "controllers/service_area_map_controller.js"
pin "controllers/hello_controller",             to: "controllers/hello_controller.js"
pin "copy-address-controller", to: "controllers/copy_address_controller.js"