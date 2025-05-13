class StripePayment < ApplicationRecord
  belongs_to :order
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true
  belongs_to :deleted_by, class_name: 'User', optional: true
  has_many :refunds,
           class_name:  'StripeRefund',
           foreign_key: :payment_intent_id,
           primary_key: :payment_intent_id,
           inverse_of:  :payment,
           dependent:   :destroy   # 決済を消したら返金も消す

  enum status: {
    requires_payment_method: 'requires_payment_method',
    requires_confirmation:   'requires_confirmation',
    requires_action:         'requires_action',
    processing:              'processing',
    requires_capture:        'requires_capture',
    canceled:                'canceled',
    succeeded:               'succeeded'
  }, _prefix: true

  validates :amount,        :platform_fee, :net_amount,
            numericality: { greater_than_or_equal_to: 0 }
  validates :currency, length: { is: 3 }
end
