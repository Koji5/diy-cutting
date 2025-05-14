class Notification < ApplicationRecord
  # 受信者ポリモーフィック
  belongs_to :recipient, polymorphic: true

  # 関連レコード（任意）
  belongs_to :related_model, polymorphic: true, optional: true

  enum channel: {
    in_app: 0, email: 1, slack: 2, sms: 3
  }, _prefix: :channel

  enum status: {
    queued: 0, sent: 1, failed: 2
  }, _prefix: :status
end
