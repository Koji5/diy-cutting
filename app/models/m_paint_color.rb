class MPaintColor < ApplicationRecord
  self.primary_key = :code
  self.table_name = "m_paint_colors"

  belongs_to :created_by, class_name: "Account", optional: true
  belongs_to :updated_by, class_name: "Account", optional: true
  belongs_to :deleted_by, class_name: "Account", optional: true

  scope :allowed_for, ->(type_code) {
    where("allow_paint_types ? :t", t: type_code) if type_code.present?
  }

  def allowed_for?(type_code)
    !!allow_paint_types[type_code]
  end
end
