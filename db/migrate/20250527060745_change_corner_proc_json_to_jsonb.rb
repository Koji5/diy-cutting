class ChangeCornerProcJsonToJsonb < ActiveRecord::Migration[8.0]
  # 既存データは破棄してよい前提で、列を削除→jsonb で再作成
  def change
    change_table :m_corner_processes do |t|
      t.remove :allow_corner_proc_json
      t.jsonb  :allow_corner_proc_json, default: {}, null: false
    end
  end
end
