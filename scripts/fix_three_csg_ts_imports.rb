#!/usr/bin/env ruby
# frozen_string_literal: true
#-------------------------------------------------------------------------------
# scripts/fix_three_csg_ts_imports.rb  (Docker‑Compose 用)
#-------------------------------------------------------------------------------
# three‑csg‑ts の .js ファイルに残っている
#   1. 拡張子なしの相対 import  → three-csg-ts/NAME
#   2. three-csg-ts/NAME.js      → three-csg-ts/NAME
# をまとめて修正し、ブラウザ ESModule + importmap 解決に合わせます。
#-------------------------------------------------------------------------------
# 使い方（プロジェクト root）
#   docker compose exec app ruby scripts/fix_three_csg_ts_imports.rb
#   docker compose run --rm app bin/importmap json
#   docker compose restart app
#-------------------------------------------------------------------------------

require 'find'
require 'pathname'

ROOT   = Pathname('/app')
TS_DIR = ROOT.join('vendor/javascript/three-csg-ts')

unless TS_DIR.directory?
  warn "[×] #{TS_DIR} が見つかりません"; exit 1
end

TARGET_EXT = '.js'

changed = []
Find.find(TS_DIR.to_s) do |path|
  next unless path.end_with?(TARGET_EXT)

  content = File.read(path)
  replaced = content
    # 1) ./Name → three-csg-ts/Name
    .gsub(/(["'`])\.(\/[^"'`]+?)(?:\.js)?(["'`])/,
          '\1three-csg-ts\2\3')
    # 2) three-csg-ts/Name.js → three-csg-ts/Name
    .gsub(/(["'`])three-csg-ts\/([^"'`]+?)\.js(["'`])/,
          '\1three-csg-ts/\2\3')

  next if replaced == content

  File.write(path, replaced)
  changed << Pathname(path).relative_path_from(ROOT)
end

if changed.empty?
  puts '[=] 変更はありません'
else
  puts "[✓] 修正済みファイル (#{changed.size})"
  changed.each { |p| puts "   - #{p}" }
end
