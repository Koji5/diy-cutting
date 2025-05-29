Rails.application.config.after_initialize do
  # 丸穴径マスタを { code => mm } でキャッシュ
  HOLE_DIAMETERS = MHoleDiameter.pluck(:code, :hole_mm).to_h.freeze
  # 例: { "D06" => 6.0, "D08" => 8.0, "D16P" => 16.0 }
end