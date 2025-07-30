class CreateMBranches < ActiveRecord::Migration[8.0]
  def change
    create_table :m_branches do |t|
      t.string :bank_code,  null: false   # 銀行コード（親）
      t.string :code,       null: false   # 支店コード（3桁）
      t.string :name,       null: false   # 支店名（漢字）
      t.string :name_kana,  null: false   # 支店名（カナ）

      t.timestamps
    end

    add_index :m_branches, [:bank_code, :code], unique: true
  end
end
