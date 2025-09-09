class CreateMHoleSpecs < ActiveRecord::Migration[8.0]
  def change
    create_table :m_hole_specs, id: false do |t|
      t.string  :code,            null: false # 例: "M6", "DOWEL8"
      t.string  :name_ja,         null: false # 例: "M6", "ダボ8mm"
      t.string  :name_en,         null: false # 例: "M6", "Dowel 8mm"
      t.string  :category_code,   null: false # "BOLT_METRIC" / "DOWEL"

      # ○ 寸法（mm）
      t.decimal :nominal_mm,              precision: 8, scale: 2, null: false # 呼び径
      t.decimal :pilot_mm,                precision: 8, scale: 2, null: false # 下穴径
      t.decimal :countersink_mm,          precision: 8, scale: 2               # 皿取り径(なければNULL)

      # ○ 安全距離（mm）
      t.decimal :min_center_center_mm,    precision: 8, scale: 2, null: false # 穴同士の最小間隔(中心～中心)
      t.decimal :min_edge_distance_mm,    precision: 8, scale: 2, null: false # 端面からの最小距離(中心～端)

      t.integer :sort_order, null: false, default: 0
      t.timestamps
    end

    execute <<~SQL
      ALTER TABLE m_hole_specs
        ADD PRIMARY KEY (code),
        ADD CONSTRAINT chk_m_hole_specs_category
          CHECK (category_code IN ('BOLT_METRIC', 'DOWEL')),
        ADD CONSTRAINT chk_m_hole_specs_positive
          CHECK (
            nominal_mm > 0 AND pilot_mm > 0 AND
            min_center_center_mm > 0 AND min_edge_distance_mm > 0
          );
    SQL

    add_index :m_hole_specs, :sort_order
  end
end
