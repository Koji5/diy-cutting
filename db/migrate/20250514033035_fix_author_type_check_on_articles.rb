class FixAuthorTypeCheckOnArticles < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      dir.up do
        # 古い CHECK を落とす（名前は \d+ articles で確認）
        execute "ALTER TABLE articles DROP CONSTRAINT IF EXISTS chk_articles_author_type"

        # 新しい CHECK を付け直す
        execute <<~SQL
          ALTER TABLE articles
          ADD CONSTRAINT chk_articles_author_type
            CHECK (author_type IN
              ('MemberDetail','VendorDetail','AdminDetail','AffiliateDetail'));
        SQL
      end

      dir.down do
        execute "ALTER TABLE articles DROP CONSTRAINT chk_articles_author_type"
        execute <<~SQL
          ALTER TABLE articles
          ADD CONSTRAINT chk_articles_author_type
            CHECK (author_type IN
              ('User','Vendor','Admin','Affiliate'));
        SQL
      end
    end
  end
end
