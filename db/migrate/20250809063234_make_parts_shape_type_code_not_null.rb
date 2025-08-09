class MakePartsShapeTypeCodeNotNull < ActiveRecord::Migration[8.0]
  def up
    # 1) NULL を埋める（暫定値は要件に合わせて変更）
    # 例: NULL の場合 'board' にする
    execute <<~SQL
      UPDATE parts
      SET shape_type_code = 'board'
      WHERE shape_type_code IS NULL;
    SQL

    # 2) NOT NULL 制約を付与
    change_column_null :parts, :shape_type_code, false
  end

  def down
    change_column_null :parts, :shape_type_code, true
  end
end
