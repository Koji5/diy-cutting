class ArticleLike < ApplicationRecord
  belongs_to :article, counter_cache: :likes_count   # AFTER TRIGGER でも可
  belongs_to :user

  # 同一ユーザーの重複いいね防止（DB UNIQUE と二重化）
  validates :user_id, uniqueness: { scope: :article_id }
end
