# db/migrate/XXXXXXXXXXXX_change_default_on_h_article_views.rb
class ChangeDefaultOnHArticleViews < ActiveRecord::Migration[8.0]
  PARENT = :h_article_views
  COLUMN = :created_at
  OLD    = 'now()'
  NEW    = 'CURRENT_TIMESTAMP'

  # ★──アップ──★
  def up
    # ❶ 親テーブル
    change_column_default PARENT, COLUMN, from: -> { OLD }, to: -> { NEW }

    # ❷ 既存パーティションすべてを動的に探して同じ変更を当てる
    partitions_of(PARENT).each do |part|
      execute <<~SQL
        ALTER TABLE #{quote_table_name(part)}
          ALTER COLUMN #{quote_column_name(COLUMN)}
          SET DEFAULT #{NEW};
      SQL
    end
  end

  # ★──ダウン──★（元に戻す）
  def down
    change_column_default PARENT, COLUMN, from: -> { NEW }, to: -> { OLD }

    partitions_of(PARENT).each do |part|
      execute <<~SQL
        ALTER TABLE #{quote_table_name(part)}
          ALTER COLUMN #{quote_column_name(COLUMN)}
          SET DEFAULT #{OLD};
      SQL
    end
  end

  private

  # INFORMATION_SCHEMA から子テーブル名を取得
  def partitions_of(parent)
    query = <<~SQL
      SELECT inhrelid::regclass::text AS part
        FROM pg_inherits
       WHERE inhparent = #{quote(parent.to_s)}::regclass
       ORDER BY part;
    SQL
    ActiveRecord::Base.connection.execute(query).values.flatten
  end
end
