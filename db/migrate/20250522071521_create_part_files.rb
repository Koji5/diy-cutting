class CreatePartFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :part_files do |t|
      t.references :part, null: false, foreign_key: true
      t.string :file_key          # ActiveStorage key など
      t.timestamps
    end
  end
end
