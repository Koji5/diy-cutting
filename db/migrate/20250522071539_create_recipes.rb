class CreateRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :recipes do |t|
      t.references :user, null: false, foreign_key: true
      t.string  :name,    null: false, limit: 60
      t.integer :status,  null: false, default: 0   # draft / published
      t.references :latest_snapshot                 # 後で FK を貼る
      t.timestamps
    end
  end
end

