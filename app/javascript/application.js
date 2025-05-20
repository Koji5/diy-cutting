// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
console.log("✅ application.js loaded");
import { Turbo } from "@hotwired/turbo-rails"
window.Turbo = Turbo
import "bootstrap"
import "controllers"
