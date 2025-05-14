class CreateHPaymentWebhooks < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  # ★親テーブルは public スキーマに
  PARENT  = 'h_payment_webhooks'

  # 直近 12 か月ぶん月別パーティション
  MONTHS = (Date.new(2025,5,1)..Date.new(2026,4,1)).select { |d| d.day == 1 }

  def up
    # 親（パーティション定義のみ）
    execute <<~SQL
      CREATE TABLE #{PARENT} (
        id                bigserial,
        gateway           varchar(30)  NOT NULL,
        event_id          varchar(255) NOT NULL,
        event_type        varchar(50)  NOT NULL,
        http_status       smallint     NOT NULL,
        signature         varchar(255),
        payload_json      jsonb        NOT NULL,
        order_id          bigint       REFERENCES orders(id),
        payout_id         bigint       REFERENCES payouts(id),
        processed_at      timestamptz,
        processing_result smallint,
        created_at        timestamptz  NOT NULL,
        CHECK (processing_result IS NULL OR processing_result IN (0,1,2))
      ) PARTITION BY RANGE (created_at);
    SQL

    # 部分インデックス（親）※UNIQUE にはしない
    add_index PARENT, [:gateway, :event_id], name: :idx_hpwebhook_gateway_event

    # 月別子パーティション作成 & 各パーティションに UNIQUE
    MONTHS.each do |d|
      part = "#{PARENT}_#{d.strftime('%Y%m')}"
      from = d.strftime('%Y-%m-%d')
      to   = (d >> 1).strftime('%Y-%m-%d')

      execute <<~SQL
        CREATE TABLE IF NOT EXISTS #{part}
          PARTITION OF #{PARENT}
          FOR VALUES FROM ('#{from}') TO ('#{to}');

        CREATE UNIQUE INDEX IF NOT EXISTS #{part}_uq
          ON #{part} (gateway, event_id);
      SQL
    end
  end

  def down
    execute "DROP TABLE IF EXISTS #{PARENT} CASCADE;"
  end
end
