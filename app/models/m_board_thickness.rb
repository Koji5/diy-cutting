class MBoardThickness < ApplicationRecord

  self.primary_key = "code"

  belongs_to :created_by, class_name: "Account", optional: true
  belongs_to :updated_by, class_name: "Account", optional: true
  belongs_to :deleted_by, class_name: "Account", optional: true

  scope :active,  -> { where(deleted_flag: false) }
  scope :ordered, -> { order(:thickness_mm) }

  validates :code,         presence: true, length: { maximum: 10 }
  validates :thickness_mm, presence: true, numericality: { greater_than: 0 }
  validates :name_ja,      presence: true, length: { maximum: 20 }
  validates :name_en,      presence: true, length: { maximum: 6 }

  def label
    "#{name_ja}（#{thickness_mm.to_f}mm）"
  end

  def soft_delete(by: nil)
    self.deleted_flag = true
    self.deleted_at   = Time.current
    self.deleted_by   = by if by
    save!
  end
end
