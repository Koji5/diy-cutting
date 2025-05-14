class OrderReview < ApplicationRecord
  self.table_name = 'order_reviews'

  # ─── Associations ─────────────────────────
  belongs_to :order
  belongs_to :reviewer, class_name: 'User'
  belongs_to :vendor,   class_name: 'User'

  # ─── Validations ──────────────────────────
  validates :rating, presence: true
  validates :order_id, uniqueness: true
  validates :title, length: { maximum: 100 }, allow_blank: true
  serialize :rating, JSON           # ← Hash として扱いたい場合
  validates :rating, presence: true, rating_json: true

  # ─── Scopes ───────────────────────────────
  scope :visible,  -> { where(deleted_flag: false) }
  scope :recent,   -> { order(created_at: :desc) }
end
