class UserAuthority < ApplicationRecord
  belongs_to :user
  belongs_to :authority,
             class_name:  "MAuthority",
             foreign_key: "authority_code",
             primary_key: "code"

  enum :grant_state, { deny: 0, grant: 1 }

  validates :authority_code, presence: true, length: { maximum: 30 }
  validates :grant_state,    presence: true
end