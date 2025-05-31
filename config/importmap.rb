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

pin "lib/eval_expr", to: "lib/eval_expr.js"

pin "three", to: "https://unpkg.com/three@0.176.0/build/three.module.js"
pin "three/examples/jsm/controls/OrbitControls.js",
    to: "https://unpkg.com/three@0.176.0/examples/jsm/controls/OrbitControls.js"
pin "three/examples/jsm/geometries/RoundedBoxGeometry.js",
    to: "https://unpkg.com/three@0.176.0/examples/jsm/geometries/RoundedBoxGeometry.js"

pin_all_from "app/javascript/helpers", under: "helpers"
pin_all_from "vendor/javascript/three-csg-ts", under: "three-csg-ts"