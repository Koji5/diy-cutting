class Part < ApplicationRecord
  belongs_to :account

  has_one :board_part, dependent: :destroy, inverse_of: :part
  has_one :lumber_part, dependent: :destroy, inverse_of: :part
  has_one_attached :thumbnail

  accepts_nested_attributes_for :board_part, update_only: true
  accepts_nested_attributes_for :lumber_part, update_only: true

  enum :shape_type_code, { board: "board", lumber: "lumber" }

  scope :boards,  -> { where(shape_type_code: :board).includes(:board_part) }
  scope :lumbers, -> { where(shape_type_code: :lumber).includes(:lumber_part) }

  validate :only_one_subtype

  private

  def only_one_subtype
    # テーブルが無い間はスキップ（本番でも冗長ではない程度のコスト）
    return unless BoardPart.table_exists?
    return unless defined?(LumberPart) && LumberPart.table_exists?

    bp = association(:board_part).loaded? ? association(:board_part).target.present? : association(:board_part).exists?
    lp = association(:lumber_part).loaded? ? association(:lumber_part).target.present? : association(:lumber_part).exists?

    if bp && lp
      errors.add(:base, "b板材か角材のどちらか一方のみを指定してください")
    end
  end

end
