# db/migrate/XXXXXXXXXXXXXX_switch_paint_fks_to_accounts.rb
class SwitchPaintFKsToAccounts < ActiveRecord::Migration[8.0]
  TABLES = %i[m_paint_types m_paint_colors].freeze
  COLUMNS = %i[created_by_id updated_by_id deleted_by_id].freeze

  def up
    TABLES.each do |table|
      COLUMNS.each do |col|
        # 既存: users へのFKを除去（制約名に依存しない）
        remove_foreign_key table, column: col rescue nil

        # 新規: accounts へのFKを付与
        add_foreign_key table, :accounts, column: col
      end
    end
  end

  def down
    TABLES.each do |table|
      COLUMNS.each do |col|
        remove_foreign_key table, column: col rescue nil
        add_foreign_key table, :users, column: col
      end
    end
  end
end
