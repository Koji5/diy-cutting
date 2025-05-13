class StripeEvent < ApplicationRecord
  self.primary_key        = :event_id
  self.inheritance_column = :_type_disabled   # STI 無効化

  enum status: {
    unprocessed: nil,
    ok:          'ok',
    error:       'error'
  }, _prefix: true

  scope :pending, -> { where(processed_at: nil) }
end
