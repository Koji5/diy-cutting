class Payout < ApplicationRecord
  # --- Polymorphic receiver -------------------------------------------------
  belongs_to :payee, polymorphic: true

  # ひも付く Stripe Payout（手動振込の場合 nil）
  belongs_to :stripe_payout,
             class_name:  'StripePayout',
             foreign_key: :transaction_ref,
             primary_key: :payout_id,
             optional:    true

  # --- Validations ----------------------------------------------------------
  validates :payee_type, presence: true
  validates :payee_id,   presence: true
  validates :net_amount, numericality: { greater_than_or_equal_to: 0 }
end
