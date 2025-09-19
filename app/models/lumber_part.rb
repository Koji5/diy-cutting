class LumberPart < ApplicationRecord
  belongs_to :part
  # マスタ参照（code 主キー）
  belongs_to :material,      class_name: "MMaterial",      primary_key: :code, foreign_key: :material_code
  belongs_to :paint_type,    class_name: "MPaintType",     primary_key: :code, foreign_key: :paint_type_code
  belongs_to :paint_color,   class_name: "MPaintColor",    primary_key: :code, foreign_key: :paint_color_code,  optional: true
  belongs_to :paint_finish,  class_name: "MPaintFinish",   primary_key: :code, foreign_key: :paint_finish_code, optional: true
  belongs_to :paint_gloss,   class_name: "MPaintGloss",    primary_key: :code, foreign_key: :paint_gloss_code,  optional: true
  belongs_to :lumber_size,   class_name: "MLumberSize",    primary_key: :code, foreign_key: :lumber_size_code

  belongs_to :created_by, class_name: "Account", optional: true
  belongs_to :updated_by, class_name: "Account", optional: true
  belongs_to :deleted_by, class_name: "Account", optional: true

  # バリデーション
  validates :material_code, :paint_type_code, :lumber_size_code, presence: true
  validates :length_mm, presence: true, numericality: { greater_than: 0 }
  validate :paint_combination_must_be_allowed

  def paint_combination_must_be_allowed
    return if paint_type_code.blank?

    if paint_color_code.present?
      color = MPaintColor.find_by(code: paint_color_code)
      errors.add(:paint_color_code, "は選択した塗装タイプでは選べません") unless color&.allowed_for?(paint_type_code)
    end

    if paint_gloss_code.present?
      gloss = MPaintGloss.find_by(code: paint_gloss_code)
      errors.add(:paint_gloss_code, "は選択した塗装タイプでは選べません") unless gloss&.allowed_for?(paint_type_code)
    end
  end
end
