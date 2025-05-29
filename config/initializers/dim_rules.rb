# frozen_string_literal: true

require "json"

json_path = Rails.root.join("config", "dim_rules.json")

raise "dim_rules.json が見つかりません" unless File.exist?(json_path)

# ① JSON → Ruby Hash（キーを symbol に）
GLOBAL_DIM_RULE = JSON.parse(
  File.read(json_path),
  symbolize_names: true
).freeze
