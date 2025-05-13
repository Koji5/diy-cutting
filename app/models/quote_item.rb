class QuoteItem < ApplicationRecord
  belongs_to :quote
  belongs_to :category,
             class_name:  'MCategory',
             foreign_key: :material_category_code,
             primary_key: :code,
             inverse_of:  :quote_items
  belongs_to :material,
             class_name:  'MMaterial',
             foreign_key: :material_code,
             primary_key: :code
  belongs_to :shape,
             class_name:  'MShape',
             foreign_key: :shape_code,
             primary_key: :code
  belongs_to :paint_type,
             class_name:  'MPaintType',
             foreign_key: :paint_type_code,
             primary_key: :code,
             optional: true
  validates :line_no,    presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :quantity,   presence: true, numericality: { greater_than: 0, only_integer: true }
end
