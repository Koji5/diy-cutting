class HPayoutEvent < ApplicationRecord
  EVENT_TYPES = %w[queued send_api paid failed retry].freeze
  self.primary_key = :id

  # associations
  belongs_to :payout

  # validations ― 必要最小限
  validates :event,       presence: true, length: { maximum: 30 }
  validates :occurred_at, presence: true
  validates :event, inclusion: { in: EVENT_TYPES }
end
