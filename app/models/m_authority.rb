class MAuthority < ApplicationRecord
  self.primary_key = :code

  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :updated_by, class_name: "User", optional: true
  belongs_to :deleted_by, class_name: "User", optional: true

  validates :code,    presence: true, length: { maximum: 30 }
  validates :name_ja, presence: true, length: { maximum: 60 }
end
