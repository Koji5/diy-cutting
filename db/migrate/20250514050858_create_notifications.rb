class CreateNotifications < ActiveRecord::Migration[8.0]
  RECIPIENT_TYPES = %w[
    MemberDetail VendorDetail AdminDetail AffiliateDetail
  ].freeze

  def change
    create_table :notifications do |t|
      # ── ポリモーフィック受信者 ─────────────────────────────
      t.string  :recipient_type, null: false
      t.bigint  :recipient_id,   null: false

      # ── 基本属性 ──────────────────────────────────────
      t.integer :channel,              null: false, limit: 2                              # smallint
      t.string  :notification_type,    null: false,  limit: 30
      t.string  :subject,              limit: 150
      t.text    :body
      t.jsonb   :payload_json

      # ── 関連オブジェクト（任意）───────────────────────
      t.string  :related_model_type,   limit: 30
      t.bigint  :related_model_id

      # ── 配信状態 ──────────────────────────────────────
      t.integer :status,               null: false, limit: 2, default: 0                 # smallint
      t.uuid    :broadcast_id,         default: "gen_random_uuid()"
      t.datetime :sent_at
      t.datetime :read_at

      # ── 系統列 ───────────────────────────────────────
      t.boolean :deleted_flag,         null: false, default: false
      t.datetime :deleted_at
      t.bigint   :deleted_by_id
      t.bigint   :created_by_id
      t.bigint   :updated_by_id
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ── CHECK 制約 ─────────────────────────────────────
    execute <<~SQL
      ALTER TABLE notifications
        ADD CONSTRAINT chk_notifications_recipient_type
        CHECK (recipient_type IN (#{RECIPIENT_TYPES.map { |v| "'#{v}'" }.join(', ')}));
    SQL

    # ── INDEX ──────────────────────────────────────────
    add_index :notifications,
              %i[recipient_type recipient_id status],
              name: :idx_notifications_recipient_status
    add_index :notifications, :notification_type
    add_index :notifications,
              %i[related_model_type related_model_id],
              name: :idx_notifications_related
    add_index :notifications, :broadcast_id

    # ── 外部キー ──────────────────────────────────────
    add_foreign_key :notifications, :users,
                    column: :created_by_id
    add_foreign_key :notifications, :users,
                    column: :updated_by_id
    add_foreign_key :notifications, :users,
                    column: :deleted_by_id
  end
end
