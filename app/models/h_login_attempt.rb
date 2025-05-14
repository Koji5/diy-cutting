class HLoginAttempt < ApplicationRecord
  self.table_name = 'h_login_attempts'

  belongs_to :user, optional: true

  enum result: { success: 0, failed: 1, locked: 2 }, _prefix: :result
end
