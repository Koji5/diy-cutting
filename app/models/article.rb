class Article < ApplicationRecord
  # ------------------------- Associations -------------------------
  #
  # 投稿者は MemberDetail / VendorDetail / AdminDetail / AffiliateDetail
  # いずれかの “ポリモーフィック関連” で表現します。
  #
  AUTHOR_TYPES = %w[MemberDetail VendorDetail AdminDetail AffiliateDetail].freeze

  belongs_to :author, polymorphic: true
  belongs_to :order,  optional: true

  # ------------------------- Validations --------------------------
  validates :author_type, inclusion: { in: AUTHOR_TYPES }
  validates :author,     presence: true
  validates :category,   presence: true, numericality: { only_integer: true }
  validates :title,      presence: true, length: { maximum: 150 }
  validates :content_blocks, presence: true
  validates :likes_count,
            :replies_count,
            :views_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # 下書きか公開かの一貫性チェック（published_at は公開時のみセット）
  validates :published_at, presence: true, unless: :is_draft?
  validates :published_at, absence:  true,  if:     :is_draft?

end
