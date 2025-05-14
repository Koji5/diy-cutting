class CreateHAuditTrails < ActiveRecord::Migration[8.0]
  # ────────────────────────────────
  # 重要ログは高速 INSERT が優先  ➜  PRIMARY KEY は付けず
  # （PK を付ける場合は id+changed_at の複合にする必要がある）
  # ────────────────────────────────
  def up
    # ❶ 親（パーティションルート）
    execute <<~SQL
      CREATE TABLE h_audit_trails (
        id            bigserial,
        table_name    varchar(60)  NOT NULL,
        pk_value      text         NOT NULL,
        action        char(1)      NOT NULL 
                       CHECK (action IN ('I','U','D')),
        changed_by    bigint       REFERENCES users(id),
        before_json   jsonb,
        after_json    jsonb,
        changed_at    timestamptz  NOT NULL DEFAULT NOW()
      ) PARTITION BY RANGE (changed_at);
    SQL

    # ❷ インデックス（親に作ると全パーティションへ自動継承）
    add_index :h_audit_trails, :id
    add_index :h_audit_trails, :table_name
    add_index :h_audit_trails, :changed_by

    # ❸ 「今月用」パーティションを 1 つだけ用意
    ym  = Time.current.strftime('%Y%m')
    y, m = ym[0,4], ym[4,2]
    start = "#{y}-#{m}-01"
    finish = (Date.parse(start) >> 1).strftime('%Y-%m-%d')

    execute <<~SQL
      CREATE TABLE h_audit_trails_#{ym}
      PARTITION OF h_audit_trails
      FOR VALUES FROM ('#{start}') TO ('#{finish}');

      CREATE INDEX ON h_audit_trails_#{ym}(id);
      CREATE INDEX ON h_audit_trails_#{ym}(table_name);
      CREATE INDEX ON h_audit_trails_#{ym}(changed_by);
    SQL
  end

  def down
    execute 'DROP TABLE IF EXISTS h_audit_trails CASCADE;'
  end
end
