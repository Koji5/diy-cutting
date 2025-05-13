class StripePayout < ApplicationRecord
  self.primary_key        = :payout_id
  self.inheritance_column = :_type_disabled   # STI 無効化

  belongs_to :account,
             class_name:  'StripeAccount',
             foreign_key: :stripe_account_id,
             primary_key: :stripe_account_id,
             inverse_of:  :payouts

  enum status: {
    paid:       'paid',
    failed:     'failed',
    in_transit: 'in_transit'
  }, _prefix: true

  validates :amount, numericality: { greater_than: 0 }
  validates :arrival_date, presence: true
end
