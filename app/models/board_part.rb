class BoardPart < ApplicationRecord
  belongs_to :part
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
