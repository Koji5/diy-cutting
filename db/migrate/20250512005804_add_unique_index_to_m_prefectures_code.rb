class AddUniqueIndexToMPrefecturesCode < ActiveRecord::Migration[8.0]
  def change
    add_index :m_prefectures, :code, unique: true
  end
end