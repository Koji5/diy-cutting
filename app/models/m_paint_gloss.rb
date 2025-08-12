class MPaintGloss < ApplicationRecord
  self.primary_key = :code
  belongs_to :created_by, class_name: "Account", optional: true
  belongs_to :updated_by, class_name: "Account", optional: true
  belongs_to :deleted_by, class_name: "Account", optional: true
end
