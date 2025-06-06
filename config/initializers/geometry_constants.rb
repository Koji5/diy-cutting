# config/initializers/geometry_constants.rb
# --------------------------------------------------------------
# 読み込んだ config/geometry.yml を Rails 設定へ取り込み、
#   - Ruby: Rails.application.config.x.geometry[:safe_edge_mm]
#   - JS:   import { GEOM_CFG } from "config/geometry";
# で共通利用できるようにする。
# --------------------------------------------------------------
Rails.application.config.x.geometry =
  Rails.application.config_for(:geometry).deep_symbolize_keys
