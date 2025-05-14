# db/migrate/20250514090444_create_h_error_logs.rb
class CreateHErrorLogs < ActiveRecord::Migration[8.0]
  # 親テーブル名
  PARENT = :h_error_logs

  # ───────────────────────────── up ─────────────────────────────
  def up
    # ❶ 親テーブル（public スキーマ・月別パーティション前提）
    execute <<~SQL
      CREATE TABLE #{PARENT} (
        id                   bigserial,                -- ★changed: PK を外す
        error_class          varchar(120) NOT NULL,
        message              text         NOT NULL,
        stacktrace_compressed bytea       NOT NULL,
        stack_head           text,
        request_path         varchar(255),
        http_method          char(6),
        status_code          smallint     NOT NULL DEFAULT 500,
        params_json          jsonb,
        user_id              bigint       REFERENCES users(id),
        request_id           char(36),
        ip_address           inet,
        user_agent           varchar(255),
        server_name          varchar(60),
        environment          char(10)     NOT NULL
                                        CHECK (environment IN ('prod','stg','dev')),
        occurred_at          timestamptz  NOT NULL,
        created_at           timestamptz  NOT NULL DEFAULT CURRENT_TIMESTAMP
        -- ★Primary Key 行を削除
      ) PARTITION BY RANGE (occurred_at);
    SQL

    # ❷ 主要インデックス
    add_index PARENT, :id                    # ★changed: b-tree 普通インデックス
    add_index PARENT, :error_class
    add_index PARENT, :request_path
    add_index PARENT, :user_id
    add_index PARENT, :request_id

    # ❸ BEFORE INSERT トリガ（stacktrace → gzip 圧縮した bytea へ格納）
    execute <<~SQL
      CREATE OR REPLACE FUNCTION tg_#{PARENT}_compress()
      RETURNS trigger LANGUAGE plpgsql AS $$
      BEGIN
        -- NEW.stacktrace はコントローラ側で text として渡す想定
        NEW.stacktrace_compressed := compress(NEW.stacktrace);
        NEW.stack_head            := left(NEW.stacktrace, 1024); -- 先頭 1 KB
        NEW.stacktrace            := NULL;                       -- 不要なら NULL
        RETURN NEW;
      END
      $$;

      CREATE TRIGGER trg_#{PARENT}_compress
        BEFORE INSERT ON #{PARENT}
        FOR EACH ROW EXECUTE FUNCTION tg_#{PARENT}_compress();
    SQL

    # ❹ 月別パーティション（今月〜 1 年分 = 12 個）
    today = Date.new(Date.today.year, Date.today.month, 1)
    12.times do |i|
      from = today >> i        # i か月後
      to   = from.next_month   # 翌月 1 日
      part = "#{PARENT}_#{from.strftime('%Y%m')}"
      execute <<~SQL
        CREATE TABLE IF NOT EXISTS #{part}
          PARTITION OF #{PARENT}
          FOR VALUES FROM ('#{from}') TO ('#{to}');
      SQL
    end
  end

  # ──────────────────────────── down ────────────────────────────
  def down
    execute "DROP TABLE IF EXISTS #{PARENT} CASCADE;"
  end
end
