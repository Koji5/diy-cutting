class ChangeMMaterialsFksToAccounts < ActiveRecord::Migration[8.0]
  def up
    # 既存のFK(users)を安全に削除（名前が環境で異なっても column 指定で外せます）
    %i[created_by_id updated_by_id deleted_by_id].each do |col|
      remove_foreign_key :m_materials, column: col if foreign_key_exists?(:m_materials, column: col)
    end

    # accounts(id) へのFKを安定した名前で付け直し
    add_foreign_key :m_materials, :accounts, column: :created_by_id, name: :fk_m_materials_created_by
    add_foreign_key :m_materials, :accounts, column: :updated_by_id, name: :fk_m_materials_updated_by
    add_foreign_key :m_materials, :accounts, column: :deleted_by_id, name: :fk_m_materials_deleted_by
  end

  def down
    # 元に戻す（users 参照へ）
    %i[created_by_id updated_by_id deleted_by_id].each do |col|
      remove_foreign_key :m_materials, column: col if foreign_key_exists?(:m_materials, column: col)
    end

    add_foreign_key :m_materials, :users, column: :created_by_id, name: :fk_m_materials_created_by
    add_foreign_key :m_materials, :users, column: :updated_by_id, name: :fk_m_materials_updated_by
    add_foreign_key :m_materials, :users, column: :deleted_by_id, name: :fk_m_materials_deleted_by
  end
end
