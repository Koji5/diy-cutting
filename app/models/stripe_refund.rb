class StripeRefund < ApplicationRecord
  self.primary_key        = :refund_id
  self.inheritance_column = :_type_disabled   # STI 無効化

  belongs_to :payment,
             class_name:  'StripePayment',
             foreign_key: :payment_intent_id,
             primary_key: :payment_intent_id,
             inverse_of:  :refunds

  enum status: {
    pending:   'pending',
    succeeded: 'succeeded',
    failed:    'failed'
  }, _prefix: true

  validates :amount, numericality: { greater_than: 0 }
  validates :reason, presence: true
end
