pin "application", to: "application.js", preload: true
#pin "@popperjs/core", to: "popperjs-core/popper.js",skip_precompile: true
#pin_all_from "popperjs-core", under: "@popperjs/core",skip_precompile: true
pin "@popperjs/core", to: "/esm/popperjs-core/popper.js"
#pin "bootstrap",     to: "bootstrap/bootstrap.esm.js",skip_precompile: true
#pin_all_from "bootstrap",      under: "bootstrap",skip_precompile: true
pin "bootstrap",      to: "/esm/bootstrap/bootstrap.esm.js"
pin "@hotwired/stimulus",        to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@hotwired/turbo-rails",      to: "turbo.min.js", preload: true
pin "@hotwired/turbo", to: "turbo.min.js", preload: true

pin "controllers",                to: "controllers/index.js"
pin_all_from "app/javascript/controllers", under: "controllers"

pin "leaflet",       to: "https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
pin "leaflet-draw",  to: "https://unpkg.com/leaflet-draw@1.0.4/dist/leaflet.draw.js"

pin "controllers/coverage_selector_controller", to: "controllers/coverage_selector_controller.js"
pin "controllers/service_area_map_controller",  to: "controllers/service_area_map_controller.js"
pin "controllers/hello_controller",             to: "controllers/hello_controller.js"
pin "copy-address-controller", to: "controllers/copy_address_controller.js"

pin "lib/eval_expr", to: "lib/eval_expr.js"

# --- Three.js 本体 -------------------------------------------------------
pin "three", to: "https://unpkg.com/three@0.176.0/build/three.module.js"
# --- BufferGeometryUtils ----------------------------------------
pin "three/examples/jsm/utils/BufferGeometryUtils.js",
    to: "https://unpkg.com/three@0.176.0/examples/jsm/utils/BufferGeometryUtils.js"
# --- OrbitControls ---------------------------------------------
pin "three/examples/jsm/controls/OrbitControls.js",
    to: "https://unpkg.com/three@0.176.0/examples/jsm/controls/OrbitControls.js"
# --- アプリ側ヘルパ -----------------------------------------------------
pin_all_from "app/javascript/helpers", under: "helpers"

pin "config/geometry", to: "config/geometry.js", preload: true
pin_all_from "vendor/javascript/three-bvh-csg", under: "three-bvh-csg"
pin_all_from "vendor/javascript/three-mesh-bvh", under: "three-mesh-bvh"
pin "sortablejs", to: "sortable.esm.js"