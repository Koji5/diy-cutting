class CreateMLumberSizes < ActiveRecord::Migration[8.0]
  def change
    create_table :m_lumber_sizes do |t|
      t.numeric :width_mm,     precision: 5, scale: 1, null: false
      t.numeric :thickness_mm, precision: 5, scale: 1, null: false
      t.string  :industry_name, limit: 50
      t.string  :hc_name,       limit: 50
      t.text    :feature
      t.integer :sort_order,    null: false, default: 0
      t.boolean :deleted_flag,  null: false, default: false

      t.timestamps
    end
  end
end
