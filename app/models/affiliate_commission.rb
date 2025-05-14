class AffiliateCommission < ApplicationRecord
  belongs_to :order
  belongs_to :affiliate_user, class_name: 'User'
  belongs_to :referred_user,  class_name: 'User'

  # simple validations
  validates :order_amount, :rate_pct, :commission_amount,
            numericality: { greater_than_or_equal_to: 0 }

  validate :paid_at_presence

  private

  def paid_at_presence
    errors.add(:paid_at, 'must be present when paid_flag is true') if paid_flag && paid_at.nil?
  end
end
