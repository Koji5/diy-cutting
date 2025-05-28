# db/migrate/XXXXXXXXXX_changePaintTypeAllowToJsonb.rb
class ChangePaintTypeAllowToJsonb < ActiveRecord::Migration[8.0]
  def change
    change_table :m_paint_types do |t|
      t.remove :allow_paint_json                       # text 列を削除
      t.jsonb  :allow_paint_json, default: {}, null: false
    end
  end
end
