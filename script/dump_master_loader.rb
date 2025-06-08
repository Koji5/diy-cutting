# frozen_string_literal: true
#
# Usage:
#   docker compose run --rm app \
#     bin/rails runner script/dump_master_loader.rb
#
# ① 開発 DB からマスター行を取得
# ② find_or_create_by! 形式で spec/support/master_loader.rb を書き出す
#
# 使い方
# docker compose run --rm app bin/rails runner script/dump_master_loader.rb


require_relative "../config/environment"

TARGETS = {
  MCategory      => %i[code name_ja name_en],
  MMaterial      => %i[code category_code name_ja name_en density_kg_per_m3],
  MShape         => %i[code name_ja name_en],
  MCornerProcess => %i[code name_ja name_en],
  MEdgeProcess   => %i[code name_ja name_en],
  MHoleDiameter  => %i[code hole_mm name_ja name_en],
  MPaintSurface  => %i[code name_ja name_en],
  MPaintColor    => %i[code name_ja name_en],
  MGrainFinish   => %i[code name_ja name_en],
  MGloss         => %i[code name_ja name_en gloss_pct],
  MPaintType     => %i[code name_ja name_en],
  # 必要に応じて追加 …
}

out_path = Rails.root.join("spec", "support", "master_loader.rb")

File.open(out_path, "w") do |f|
  f.puts "# frozen_string_literal: true"
  f.puts
  f.puts "module MasterLoader"
  f.puts "  def self.load!"
  f.puts

  TARGETS.each do |klass, cols|
    klass.order(:code).each do |rec|
      # --- 主キー（code）は find_or_create_by! の第一引数に ---
      f.print "    #{klass.name}.find_or_create_by!(code: #{rec.code.inspect})"

      # --- ブロック内でその他属性を assign ----------------------
      assigns = cols.reject { |c| c == :code }.map do |c|
        "#{c}: #{rec.public_send(c).inspect}"
      end.join(", ")

      if assigns.empty?
        f.puts
      else
        f.puts " { |m| m.assign_attributes(#{assigns}) }"
      end
    end
    f.puts
  end
  f.puts "    cache = MHoleDiameter.pluck(:code, :hole_mm).to_h.freeze"
  f.puts "    Object.send(:remove_const, :HOLE_DIAMETERS) if Object.const_defined?(:HOLE_DIAMETERS)"
  f.puts "    Object.const_set(:HOLE_DIAMETERS, cache)"
  f.puts "  end"
  f.puts "end"
end

puts "✅  Generated #{out_path.relative_path_from(Rails.root)}"
