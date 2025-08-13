class Part < ApplicationRecord
  belongs_to :account

  has_one :board_part, dependent: :destroy
  has_one :lumber_part, dependent: :destroy

  accepts_nested_attributes_for :board_part
  accepts_nested_attributes_for :lumber_part

  enum :shape_type_code, { board: "board", lumber: "lumber" }

  scope :boards,  -> { where(shape_type_code: :board).includes(:board_part) }
  scope :lumbers, -> { where(shape_type_code: :lumber).includes(:lumber_part) }

  validate :only_one_subtype

  private

  def only_one_subtype
    count = [board_part&.changed? || board_part&.persisted?,
             lumber_part&.changed? || lumber_part&.persisted?].count(true)
    errors.add(:base, "板材か角材のどちらか一方のみを指定してください") if count > 1
  end

end
