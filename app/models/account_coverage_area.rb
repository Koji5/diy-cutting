class AccountCoverageArea < ApplicationRecord
  belongs_to :account

  validates :city_code, presence: true
end
