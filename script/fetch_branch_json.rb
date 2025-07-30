#!/usr/bin/env ruby
# frozen_string_literal: true

# ============================================
# 金融機関マスタ・支店マスタを GitHub から取得して
# db/data/banks.json および db/data/branches/*.json に保存します。
#
# 実行例:
#   docker compose run --rm app rails runner script/fetch_branch_json.rb
#
# 事前条件:
#   - banks.json と branches/*.json を保存する db/data/ ディレクトリが存在すること
# ============================================

require "json"
require "open-uri"
require "fileutils"

banks_url    = "https://raw.githubusercontent.com/zengin-code/source-data/master/data/banks.json"
branches_dir = "db/data/branches"
banks_path   = "db/data/banks.json"

FileUtils.mkdir_p(branches_dir)

puts "📥 banks.json をダウンロード中..."
begin
  URI.open(banks_url) do |remote|
    File.write(banks_path, remote.read)
  end
  puts "✅ banks.json を保存しました → #{banks_path}"
rescue => e
  abort("❌ banks.json の取得に失敗しました: #{e.message}")
end

banks_data = JSON.parse(File.read(banks_path))

banks_data.each do |bank_code, _|
  branch_url  = "https://raw.githubusercontent.com/zengin-code/source-data/master/data/branches/#{bank_code}.json"
  branch_path = "#{branches_dir}/#{bank_code}.json"

  begin
    puts "📥 branches/#{bank_code}.json をダウンロード中..."
    URI.open(branch_url) do |remote|
      File.write(branch_path, remote.read)
    end
  rescue OpenURI::HTTPError => e
    puts "⚠️  branches/#{bank_code}.json の取得に失敗: #{e.message}"
  end
end

puts "🎉 銀行・支店データの取得が完了しました。"
