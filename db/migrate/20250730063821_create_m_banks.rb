class CreateMBanks < ActiveRecord::Migration[8.0]
  def change
    create_table :m_banks do |t|
      t.string :code,       null: false   # 銀行コード（4桁）
      t.string :name,       null: false   # 銀行名（漢字）
      t.string :name_kana,  null: false   # 銀行名（カナ）

      t.timestamps
    end

    add_index :m_banks, :code, unique: true
  end
end
