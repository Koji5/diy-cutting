# db/migrate/20250514052343_create_h_login_attempts.rb
class CreateHLoginAttempts < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  RESULT_CHECK = 'CHECK (result IN (0,1,2))'

  def up
    # 1. 親パーティション
    execute <<~SQL
      CREATE TABLE h_login_attempts (
        id            bigserial,
        user_id       bigint      REFERENCES users(id),
        email_tried   varchar(255) NOT NULL,
        ip_address    inet         NOT NULL,
        user_agent    text         NOT NULL,
        result        smallint     NOT NULL,
        created_at    timestamptz  NOT NULL,
        #{RESULT_CHECK}
      ) PARTITION BY RANGE (created_at);
    SQL

    # ---------- 親テーブル：インデックス (concurrently なし) ----------
    add_index :h_login_attempts, :id
    add_index :h_login_attempts, :user_id
    add_index :h_login_attempts, :ip_address

    # 2. 直近 1 ヶ月パーティションを例で作成
    yyyymm = Time.current.strftime('%Y%m')
    from   = Time.current.beginning_of_month.utc.strftime('%Y-%m-%d')
    to     = (Time.current.beginning_of_month + 1.month).utc.strftime('%Y-%m-%d')

    execute <<~SQL
      CREATE TABLE h_login_attempts_#{yyyymm}
        PARTITION OF h_login_attempts
        FOR VALUES FROM ('#{from}') TO ('#{to}');
    SQL

    # ---------- 子パーティションにインデックス ----------
    execute <<~SQL
      CREATE INDEX ON h_login_attempts_#{yyyymm}(id);
      CREATE INDEX ON h_login_attempts_#{yyyymm}(user_id);
      CREATE INDEX ON h_login_attempts_#{yyyymm}(ip_address);
    SQL
  end

  def down
    execute 'DROP TABLE IF EXISTS h_login_attempts CASCADE;'
  end
end
