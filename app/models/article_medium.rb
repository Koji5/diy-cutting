class ArticleMedium < ApplicationRecord
  self.table_name = 'article_media'

  belongs_to :article

  # enum にする場合は後から
  # enum media_type: { image: 0, video: 1 }
end
