# db/migrate/XXXXXXXXXX_create_stripe_events.rb
class CreateStripeEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :stripe_events,
                 id: false,                # id カラムを生成しない
                 primary_key: :event_id do |t|

      t.string  :event_id,   null: false, limit: 255          # PK
      t.string  :account_id, null: false, limit: 255
      t.string  :type,       null: false, limit: 64
      t.jsonb   :payload,    null: false

      t.datetime :received_at,  null: false,
                 default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :processed_at
      t.string   :status,     limit: 16      # ok / error など

      # メタ・トラッキング列は不要なので省略（ログ用途）
    end

    # よく使う検索に備え軽めのインデックス
    add_index :stripe_events, :account_id
    add_index :stripe_events, :status
    add_index :stripe_events, :processed_at
  end
end
