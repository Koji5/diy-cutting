# frozen_string_literal: true
# script/generate_table_docs_from_db.rb
#
# - SECTION / TABLE / NOTE すべての順序と内容を保持しつつ再生成
# - モデルをロードせず DB メタ情報のみで Markdown を更新
# - NULL 列は ○（NULL 可） / ×（NULL 不可）
# - 生成日時は JST
#
# 実行例:
#   docker compose run --rm app rails runner script/generate_table_docs_from_db.rb
#
#初回生成        	既存 docs/db/tables.md を削除 → 上記スクリプト実行
#セクション追加	   Markdown に <!-- SECTION_BEGIN 新グループ --> … <!-- SECTION_END … --> を追記し、テーブルブロックをその直後へドラッグ
#テーブル移動	     <!-- TABLE_BEGIN … --> … <!-- TABLE_END … --> を切り取り、ターゲットセクションの下へ貼り付け
#--------------------------------------------------------------------

require_relative '../config/environment'
require 'fileutils'

OUTPUT = 'docs/db/tables.md'
FileUtils.mkdir_p(File.dirname(OUTPUT))

#--------------------------------------------------------------------
# 1. 既存 Markdown をパースして順序と説明・メモを収集
#--------------------------------------------------------------------
ordered_items = []                           # [{type: :section, name:'ユーザー系'}, {type: :table, name:'users'}…]
descriptions  = Hash.new { |h, k| h[k] = {} }# {table => {col => desc}}
headlines     = {}                           # {table => '## usersー説明'}
notes         = {}                           # {table => "<本文…>"}

current_section  = nil
current_table    = nil
in_auto_block    = false
in_note_block    = false
note_buffer      = []

if File.exist?(OUTPUT)
  File.foreach(OUTPUT, chomp: true) do |line|
    case line
    # ---- セクション
    when /<!--\s*SECTION_BEGIN\s+(.+?)\s*-->/
      current_section = Regexp.last_match(1)
      ordered_items << { type: :section, name: current_section }

    when /<!--\s*SECTION_END\s+(.+?)\s*-->/
      current_section = nil

    # ---- テーブル
    when /<!--\s*TABLE_BEGIN\s+([A-Za-z0-9_]+)\s*-->/
      current_table = Regexp.last_match(1)
      ordered_items << { type: :table, name: current_table, section: current_section }

    when /<!--\s*TABLE_END\s+([A-Za-z0-9_]+)\s*-->/
      # NOTE flush
      if in_note_block && current_table
        notes[current_table] = note_buffer.join("\n") unless note_buffer.empty?
      end
      current_table = nil
      in_auto_block = false
      in_note_block = false
      note_buffer   = []

    # ---- AUTO ブロック境界
    when /<!--\s*AUTO BEGIN\s*-->/
      in_auto_block = true if current_table
    when /<!--\s*AUTO END\s*-->/
      in_auto_block = false

    # ---- NOTE ブロック境界
    when /<!--\s*NOTE BEGIN\s*-->/
      in_note_block = true
      note_buffer   = []
    when /<!--\s*NOTE END\s*-->/
      if current_table
        notes[current_table] = note_buffer.join("\n") unless note_buffer.empty?
      end
      in_note_block = false

    # ---- ヘッダ全文
    when /^##\s+(.+)/
      headlines[current_table] = Regexp.last_match(1) if current_table

    # ---- 自動テーブル行
    else
      if in_auto_block && line.start_with?('|')
        cells = line.split('|').map(&:strip)
        next if cells[1] == '型'
        col, _type, _null, _def, desc = cells[1, 5]
        descriptions[current_table][col] = desc unless desc.empty?
      end

      note_buffer << line if in_note_block
    end
  end
end

table_order = ordered_items.select { |i| i[:type] == :table }.map { |i| i[:name] }

#--------------------------------------------------------------------
# 2. DB から最新テーブル取得し順序統合
#--------------------------------------------------------------------
conn          = ActiveRecord::Base.connection
all_tables    = conn.tables
ordered_tables = (table_order & all_tables) + (all_tables - table_order)

# SECTION のない新規テーブルを末尾に追加するため、最後に特殊セクションを挿入
ordered_items += ordered_tables.reject { |t| table_order.include?(t) }
                               .map { |t| { type: :table, name: t, section: nil } }

#--------------------------------------------------------------------
# 3. Markdown を再構築
#--------------------------------------------------------------------
timestamp = Time.now.in_time_zone('Asia/Tokyo').strftime('%Y-%m-%d %H:%M %Z')
md = +"# DB テーブル一覧\n\n生成日: #{timestamp}\n\n"

ordered_items.each do |item|
  case item[:type]
  when :section
    title = item[:name]
    md << "<!-- SECTION_BEGIN #{title} -->\n"
    md << "# #{title}\n"
    md << "<!-- SECTION_END #{title} -->\n\n"

  when :table
    table = item[:name]
    md << "<!-- TABLE_BEGIN #{table} -->\n"
    headline_text = headlines[table] || table        # ← 先頭の ## はあとで付ける
    md << "## #{headline_text}\n\n"                  # ← 常に ## を付与

    md << "<!-- AUTO BEGIN -->\n"
    md << "| 列名 | 型 | NULL | デフォルト | 説明 |\n"
    md << "|------|----|------|-----------|------|\n"

    conn.columns(table).each do |col|
      nullable = col.null ? '○' : '×'               # ここを ○ / ×
      default  = col.default.nil? ? '' : col.default.to_s
      desc     = descriptions.dig(table, col.name) || ''
      md << "| #{col.name} | #{col.sql_type} | #{nullable} | #{default} | #{desc} |\n"
    end

    indexes = conn.indexes(table)
    unless indexes.empty?
      md << "\n**インデックス**:\n"
      indexes.each { |idx| md << "- #{idx.name}\n" }
    end

    fks = conn.foreign_keys(table)
    unless fks.empty?
      md << "\n**外部キー**:\n"
      fks.each { |fk| md << "- (#{fk.column}) → #{fk.to_table}.#{fk.primary_key}\n" }
    end

    md << "<!-- AUTO END -->\n\n"

    if notes.key?(table)
      md << "<!-- NOTE BEGIN -->\n"
      md << notes[table] << "\n"
      md << "<!-- NOTE END -->\n\n"
    else
      md << "<!-- NOTE BEGIN -->\n<!-- 任意のメモを書いてください -->\n<!-- NOTE END -->\n\n"
    end

    md << "<!-- TABLE_END #{table} -->\n\n"
  end
end

#--------------------------------------------------------------------
# 4. 書き込み
#--------------------------------------------------------------------
File.write(OUTPUT, md)
puts "✅ #{OUTPUT} を更新しました (#{timestamp})"
