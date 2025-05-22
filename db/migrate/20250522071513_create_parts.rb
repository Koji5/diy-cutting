# db/migrate/xxxx_create_parts.rb
class CreateParts < ActiveRecord::Migration[8.0]
  def change
    create_table :parts do |t|
      t.references :user,      null: false, foreign_key: true
      t.string     :name,      null: false, limit: 50
      t.timestamps
    end
  end
end
