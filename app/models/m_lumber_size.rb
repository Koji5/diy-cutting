class MLumberSize < ApplicationRecord
  self.primary_key = :code

  belongs_to :created_by, class_name: "Account", optional: true, foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "Account", optional: true, foreign_key: :updated_by_id
  belongs_to :deleted_by, class_name: "Account", optional: true, foreign_key: :deleted_by_id

  # --- Soft delete ヘルパ ---
  scope :active,   -> { where(deleted_flag: false) }
  scope :deleted,  -> { where(deleted_flag: true) }
  scope :ordered,  -> { order(:sort_order, :width_mm, :thickness_mm) }

  # --- Validation ---
  validates :code, presence: true, uniqueness: true, length: { maximum: 32 }
  validates :width_mm,     presence: true, numericality: true
  validates :thickness_mm, presence: true, numericality: true
  validates :industry_name, length: { maximum: 50 }, allow_blank: true
  validates :hc_name,       length: { maximum: 50 }, allow_blank: true

  # 幅×厚から code を自動生成（手動指定があれば尊重）
  before_validation :ensure_code

  # 表示用ラベル
  def label
    names = [industry_name, hc_name].compact_blank
    "#{width_mm.to_i}×#{thickness_mm.to_i} (#{names.join(' / ')})"
  end

  private

  def ensure_code
    return if code.present?
    # 小数サイズも想定するなら format を見直してください（例: 38.5→"38.5x89"）
    w = width_mm.to_f % 1 == 0 ? width_mm.to_i : width_mm.to_f
    t = thickness_mm.to_f % 1 == 0 ? thickness_mm.to_i : thickness_mm.to_f
    self.code = "#{w}x#{t}"
  end
end
