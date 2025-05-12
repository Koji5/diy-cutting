class AddUniqueIndexToMCitiesCode < ActiveRecord::Migration[8.0]
  def change
    add_index :m_cities, :code, unique: true
  end
end