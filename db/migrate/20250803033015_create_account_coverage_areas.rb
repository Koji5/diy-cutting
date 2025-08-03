class CreateAccountCoverageAreas < ActiveRecord::Migration[8.0]
  def change
    create_table :account_coverage_areas do |t|
      t.references :account, null: false, foreign_key: true
      t.string :city_code, null: false
      t.timestamps
    end
    add_foreign_key :account_coverage_areas, :m_cities, column: :city_code, primary_key: :code
    add_index :account_coverage_areas, [:account_id, :city_code], unique: true
    add_index :account_coverage_areas, :city_code
  end
end
