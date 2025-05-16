class ShrinkCityCodeTo5Char < ActiveRecord::Migration[8.0]
  MAIN_TBL = :m_cities
  MAIN_COL = :code
  FK_TABLES = {
    member_details:            :billing_city_code,
    member_shipping_addresses: :city_code,
    vendor_details:            :office_city_code,
    vendor_service_areas:      :city_code,
    affiliate_details:         :city_code
  }

  def up
    # 1) FK を一旦外す
    FK_TABLES.each do |tbl, col|
      fk_name = fk_name(tbl, col)
      remove_foreign_key tbl, name: fk_name if foreign_key_exists?(tbl, name: fk_name)
    end

    # 2) m_cities の制約を外す
    execute "ALTER TABLE #{MAIN_TBL} DROP CONSTRAINT IF EXISTS m_cities_code_len_chk"

    # 3) 参照側を 5 桁へ切り詰め
    FK_TABLES.each { |tbl, col| execute "UPDATE #{tbl} SET #{col}=SUBSTRING(#{col} FROM 1 FOR 5)" }

    # 4) m_cities も 5 桁へ切り詰め
    execute "UPDATE #{MAIN_TBL} SET #{MAIN_COL}=SUBSTRING(#{MAIN_COL} FROM 1 FOR 5)"

    # 5) 列型を 5 桁に変更
    change_column MAIN_TBL, MAIN_COL, :string, limit: 5
    FK_TABLES.each { |tbl, col| change_column tbl, col, :string, limit: 5 }

    # 6) 新しい CHECK(=5) を張る
    execute <<~SQL
      ALTER TABLE #{MAIN_TBL}
      ADD CONSTRAINT m_cities_code_len_chk CHECK (char_length(#{MAIN_COL}) = 5)
    SQL

    # 7) FK を張り直す
    FK_TABLES.each do |tbl, col|
      add_foreign_key tbl, MAIN_TBL, column: col, primary_key: MAIN_COL, name: fk_name(tbl, col)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  # 参照 FK 名を生成（既存命名に合わせる）
  def fk_name(tbl, col)
    "fk_#{tbl}_#{col}"
  end
end
