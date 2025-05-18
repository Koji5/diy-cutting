# Pin npm packages by running ./bin/importmap

pin "application"
pin "@popperjs/core", to: "@popperjs--core.js" # @2.11.8
pin "bootstrap", to: "bootstrap.bundle.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "controllers",                to: "controllers/index.js"
pin_all_from "app/javascript/controllers", under: "controllers"
