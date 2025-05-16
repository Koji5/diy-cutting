class CreateMPostalCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :m_postal_codes do |t|
      t.string  :postal_code, limit: 7, null: false
      t.string  :city_code,   limit: 5, null: false
      t.string  :city_town_name_kanji,  limit: 150, null: false
      t.string  :town_area_name_kanji,  limit: 150
      t.boolean :multi_town_flag,   null: false, default: false
      t.boolean :koaza_banchi_flag, null: false, default: false
      t.boolean :chome_flag,        null: false, default: false
      t.boolean :multi_aza_flag,    null: false, default: false
      t.boolean :deleted_flag,      null: false, default: false

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.references :deleted_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    # 制約・インデックス
    add_check_constraint :m_postal_codes,
      "char_length(postal_code) = 7", name: "postal_code_len_chk"
    add_check_constraint :m_postal_codes,
      "char_length(city_code)   = 5", name: "postal_city_len_chk"

    add_index :m_postal_codes, :postal_code
    add_index :m_postal_codes, :city_code
    add_index :m_postal_codes,
              %i[postal_code town_area_name_kanji],
              unique: true,
              name: "idx_postal_code_area_unique"

    add_foreign_key :m_postal_codes,
                    :m_cities,
                    column: :city_code,
                    primary_key: :code
  end
end
