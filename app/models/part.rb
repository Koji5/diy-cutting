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
             primary_key: :code

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

  # ─────────────────────────────
  # バリデーション
  # ─────────────────────────────
  validates :name, presence: true, length: { maximum: 50 }

  with_options numericality: { greater_than: 0 } do
    validates :thickness_mm
    validates :width1_mm
    validates :length_mm
    validates :width2_mm, allow_nil: true
  end

  validates :material_category_code, :material_code,
            :shape_code, presence: true

  # ソフトデリート用スコープ
  scope :alive, -> { where(deleted_flag: false) }
end
