class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.references :account, null: false, foreign_key: true
      t.string :postal_code, limit: 7
      t.string :prefecture_code, limit: 2
      t.string :city_code, limit: 5
      t.string :address_line, limit: 200
      t.string :recipient_name, limit: 100
      t.string :phone_number, limit: 30
      t.string :label, limit: 50  # "自宅", "会社" など任意ラベル
      t.boolean :default_flag, null: false, default: false
      t.timestamps
    end
    add_foreign_key :addresses, :m_prefectures, column: :prefecture_code, primary_key: :code
    add_foreign_key :addresses, :m_cities, column: :city_code, primary_key: :code
  end
end
