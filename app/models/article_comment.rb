class ArticleComment < ApplicationRecord
  belongs_to :article
  belongs_to :parent,   class_name: 'ArticleComment', optional: true
  has_many   :children, class_name: 'ArticleComment',
                        foreign_key: :parent_id,
                        dependent: :restrict_with_error

  # ポリモーフィック投稿者
  belongs_to :author, polymorphic: true

  validates :body, presence: true
end
