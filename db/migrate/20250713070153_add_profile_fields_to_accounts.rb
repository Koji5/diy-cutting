class AddProfileFieldsToAccounts < ActiveRecord::Migration[8.0]
  def change
    change_table :accounts, bulk: true do |t|
      t.string  :nickname, limit: 50
      t.integer :legal_type, null: false, default: 0
      t.string  :name, null: false, default: ""
      t.string  :name_kana
      t.date    :birthday
      t.string  :gender, limit: 1
    end
  end
end
