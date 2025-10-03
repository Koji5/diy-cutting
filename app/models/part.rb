class Part < ApplicationRecord
  belongs_to :account

  has_one :board_part, dependent: :destroy, inverse_of: :part
  has_one :lumber_part, dependent: :destroy, inverse_of: :part
  has_one_attached :thumbnail, dependent: :purge_later
  has_one_attached :geometry, dependent: :purge_later

  accepts_nested_attributes_for :board_part, update_only: true
  accepts_nested_attributes_for :lumber_part, update_only: true

  enum :shape_type_code, { board: "board", lumber: "lumber" }

  scope :boards,  -> { where(shape_type_code: :board).includes(:board_part) }
  scope :lumbers, -> { where(shape_type_code: :lumber).includes(:lumber_part) }

  validate :only_one_subtype

  private

  def only_one_subtype
    return unless defined?(BoardPart)  && BoardPart.table_exists?
    return unless defined?(LumberPart) && LumberPart.table_exists?

    # メモリ上（nested attributes で build された場合は target に入る）
    bp_target = association(:board_part).target
    lp_target = association(:lumber_part).target

    # 永続化済みなら DB にも存在確認（Relation.exists? を使う）
    bp_db = persisted? ? BoardPart.where(part_id: id).exists?  : false
    lp_db = persisted? ? LumberPart.where(part_id: id).exists? : false

    bp = bp_target.present? || bp_db
    lp = lp_target.present? || lp_db

    if bp && lp
      errors.add(:base, "板材か角材のどちらか一方のみを指定してください")
    end
  end

end
