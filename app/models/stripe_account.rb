class StripeAccount < ApplicationRecord
  self.primary_key = :user_id

  # Associations
  belongs_to :user
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true
  belongs_to :deleted_by, class_name: 'User', optional: true

  # Validations
  validates :stripe_account_id, presence: true, length: { maximum: 255 }
  validates :charges_enabled, :payouts_enabled, inclusion: { in: [true, false] }
end
