class QuoteRequestComment < ApplicationRecord
  belongs_to :quote_request
  belongs_to :parent,  class_name: 'QuoteRequestComment', optional: true
  has_many   :children, class_name: 'QuoteRequestComment',
                        foreign_key: :parent_id, dependent: :destroy

  belongs_to :author, polymorphic: true

  validates :body, presence: true
  validates :author, presence: true
end
