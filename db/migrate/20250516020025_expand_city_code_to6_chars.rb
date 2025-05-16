# db/migrate/20240516_expand_city_code_to6_chars.rb
class ExpandCityCodeTo6Chars < ActiveRecord::Migration[8.0]
  TABLES_FK = {
    member_details:              :billing_city_code,
    member_shipping_addresses:   :city_code,
    vendor_details:              :office_city_code,
    vendor_service_areas:        :city_code,
    affiliate_details:           :city_code
  }

  def up
    # 1) m_cities.code
    change_column :m_cities, :code, :string, limit: 6
    execute "ALTER TABLE m_cities DROP CONSTRAINT IF EXISTS m_cities_code_len_chk"
    execute "ALTER TABLE m_cities ADD CONSTRAINT m_cities_code_len_chk CHECK (char_length(code)=6)"

    # 2) 参照側
    TABLES_FK.each do |tbl, col|
      change_column tbl, col, :string, limit: 6
    end
  end

  def down
    execute "ALTER TABLE m_cities DROP CONSTRAINT m_cities_code_len_chk"
    change_column :m_cities, :code, :string, limit: 5
    execute "ALTER TABLE m_cities ADD CONSTRAINT m_cities_code_len_chk CHECK (char_length(code)=5)"

    TABLES_FK.each do |tbl, col|
      change_column tbl, col, :string, limit: 5
    end
  end
end
