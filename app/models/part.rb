class Part < ApplicationRecord
  # ─────────────────────────────
  # 関連
  # ─────────────────────────────
  belongs_to :user

  belongs_to :material_category,
             class_name:  'MCategory',
             foreign_key: :material_category_code,
             primary_key: :code

  belongs_to :material,
             class_name:  'MMaterial',
             foreign_key: :material_code,
             primary_key: :code, optional: true

  belongs_to :shape,
             class_name:  'MShape',
             foreign_key: :shape_code,
             primary_key: :code

  belongs_to :paint_type,
             class_name:  'MPaintType',
             foreign_key: :paint_type_code,
             primary_key: :code,
             optional:    true                   # NULL 許容
  belongs_to :origin_owner,
             class_name:  "User",
             foreign_key: :origin_owner_id,
             optional:    true
  # ─────────────────────────────
  # JSONB アクセサ
  # ─────────────────────────────
  store_accessor :shape_json,       :tl, :tr, :bl, :br
  store_accessor :corner_proc_json, :corner_tl, :corner_tr, :corner_bl, :corner_br
  store_accessor :hole_json,        :hole_tl, :hole_tr, :hole_bl, :hole_br
  store_accessor :sqhole_json,      :sqhole_tl, :sqhole_tr, :sqhole_bl, :sqhole_br
  store_accessor :edge_json,        :edge_t, :edge_b, :edge_l, :edge_r
  store_accessor :paint_json,       :surface, :color, :finish, :gloss

  # 1) 平面形状の半径 4 点
  store_accessor :shape_json,
                :shape_tl_r, :shape_tr_r, :shape_bl_r, :shape_br_r

  # 2) 丸穴（hole_json）―― 4 方向 × (flag / dia_code / dia_mm / dx / dy)
  store_accessor :hole_json,
                :hole_tl_flag, :hole_tr_flag, :hole_bl_flag, :hole_br_flag,
                :hole_tl_dia_code, :hole_tr_dia_code, :hole_bl_dia_code, :hole_br_dia_code,
                :hole_tl_dia_mm,   :hole_tr_dia_mm,   :hole_bl_dia_mm,   :hole_br_dia_mm,
                :hole_tl_dx,       :hole_tr_dx,       :hole_bl_dx,       :hole_br_dx,
                :hole_tl_dy,       :hole_tr_dy,       :hole_bl_dy,       :hole_br_dy

  # 3) 四角穴（sqhole_json）―― 4 方向 × (flag / dx / dy / h / w)
  store_accessor :sqhole_json,
                :sqhole_tl_flag, :sqhole_tr_flag, :sqhole_bl_flag, :sqhole_br_flag,
                :sqhole_tl_dx,   :sqhole_tr_dx,   :sqhole_bl_dx,   :sqhole_br_dx,
                :sqhole_tl_dy,   :sqhole_tr_dy,   :sqhole_bl_dy,   :sqhole_br_dy,
                :sqhole_tl_h,    :sqhole_tr_h,    :sqhole_bl_h,    :sqhole_br_h,
                :sqhole_tl_w,    :sqhole_tr_w,    :sqhole_bl_w,    :sqhole_br_w
  # ─────────────────────────────
  # バリデーション
  # ─────────────────────────────
  validates_with DimensionValidator
 
  # ソフトデリート用スコープ
  scope :alive, -> { where(deleted_flag: false) }

  private

  def auto_length_locked
    auto_shapes = %w[TRI_EQ CIRC SEMI CORNER_TRI]
    if auto_shapes.include?(shape_code) && length_mm != width1_mm
      errors.add(:length_mm, "は自動入力されます")
    end
  end
end
