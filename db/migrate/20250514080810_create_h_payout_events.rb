class CreateHPayoutEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :h_payout_events, id: :bigserial do |t|
      t.bigint     :payout_id,     null: false                            # FK 手動追加
      t.string     :event,         null: false, limit: 30
      t.jsonb      :meta_json
      t.datetime   :occurred_at,   null: false
      t.string     :logged_by_type, limit: 20
      t.bigint     :logged_by_id
      t.datetime   :created_at,    null: false, default: -> { 'CURRENT_TIMESTAMP' }

      # チェック制約（ログ生成主体）
      t.check_constraint "logged_by_type IN ('System','User','Admin') OR logged_by_type IS NULL",
                         name: :chk_hpe_logged_by_type
    end

    # ─── 外部キー（NULL 可にしたいので separate で追加） ───
    add_foreign_key :h_payout_events, :payouts

    # ─── インデックス ───
    add_index :h_payout_events, :payout_id
    add_index :h_payout_events, :event
    add_index :h_payout_events, :occurred_at
    add_index :h_payout_events, %i[logged_by_type logged_by_id],
              name: :idx_hpe_logger
  end
end
