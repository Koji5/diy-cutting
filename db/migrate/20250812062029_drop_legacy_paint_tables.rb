# db/migrate/XXXXXXXXXXXXXX_drop_legacy_paint_tables.rb
class DropLegacyPaintTables < ActiveRecord::Migration[8.0]
  def up
    # 参照FKが残っているとエラーになるので、心当たりがあれば先に remove_foreign_key してください。
    # 例) remove_foreign_key :some_table, column: :m_gloss_code

    drop_table :m_paint_surfaces, if_exists: true
    drop_table :m_grain_finishes, if_exists: true
    drop_table :m_glosses,        if_exists: true
  end

  def down
    # 元スキーマが不明なため復元不可とします
    raise ActiveRecord::IrreversibleMigration
  end
end
