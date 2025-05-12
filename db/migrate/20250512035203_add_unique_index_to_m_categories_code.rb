class AddUniqueIndexToMCategoriesCode < ActiveRecord::Migration[8.0]
  def change
    add_index :m_categories, :code, unique: true
  end
end