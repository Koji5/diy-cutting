class CreateHArticleViews < ActiveRecord::Migration[8.0]
  # 最初に 12 か月ぶんだけ空パーティションを用意
  START_MONTH = Date.new(2025, 5, 1)     # ←必要に応じて変更
  PARTS       = 12                       # 12 か月

  def up
    # 親テーブル（partition definition のみ）
    execute <<~SQL
      CREATE TABLE h_article_views (
        id             bigserial,
        article_id     bigint      NOT NULL REFERENCES articles(id),
        user_id        bigint      REFERENCES users(id),
        ip_address     inet,
        viewed_at      timestamptz NOT NULL,
        ua_hash        char(32),
        processed_flag boolean     NOT NULL DEFAULT false,
        created_at     timestamptz NOT NULL DEFAULT now()
      ) PARTITION BY RANGE (viewed_at);
    SQL

    # 汎用 INDEX
    add_index :h_article_views, :id
    add_index :h_article_views, :article_id
    add_index :h_article_views, :user_id

    # 未処理だけを掃く部分 INDEX
    execute <<~SQL
      CREATE INDEX idx_article_views_unprocessed
        ON h_article_views (article_id)
       WHERE processed_flag = false;
    SQL

    # ── 月別パーティションを必要月ぶん作る ──
    PARTS.times do |i|
      from = (START_MONTH >> i)                       # N ヶ月後
      to   = (START_MONTH >> (i + 1))
      part = "h_article_views_#{from.strftime('%Y%m')}"
      execute <<~SQL
        CREATE TABLE IF NOT EXISTS #{part}
          PARTITION OF h_article_views
          FOR VALUES FROM ('#{from}') TO ('#{to}');

        -- 部分 INDEX を各パーティションにも作成
        CREATE INDEX IF NOT EXISTS #{part}_unproc_idx
          ON #{part} (article_id)
         WHERE processed_flag = false;
      SQL
    end
  end

  def down
    execute "DROP TABLE IF EXISTS h_article_views CASCADE;"
  end
end
