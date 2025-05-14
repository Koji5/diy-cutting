# db/migrate/20250513XXXXXX_create_order_reviews.rb
class CreateOrderReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :order_reviews do |t|
      t.references :order,      null: false, foreign_key: true,  index: { unique: true }
      t.bigint     :reviewer_id,               null: false,       index: true
      t.bigint     :vendor_id,                 null: false,       index: true

      t.jsonb      :rating,     null: false                        # { quality:5, support:4, ... }
      t.string     :title,      limit: 100
      t.text       :comment
      t.text       :vendor_reply
      t.datetime   :replied_at

      # メタ
      t.boolean    :deleted_flag,    null: false, default: false
      t.datetime   :deleted_at
      t.bigint     :deleted_by_id,                   index: true
      t.bigint     :created_by_id,                   index: true
      t.bigint     :updated_by_id,                   index: true
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ---- 追加インデックス・FK ----
    add_foreign_key :order_reviews, :users, column: :reviewer_id
    add_foreign_key :order_reviews, :users, column: :vendor_id
    add_foreign_key :order_reviews, :users, column: :deleted_by_id
    add_foreign_key :order_reviews, :users, column: :created_by_id
    add_foreign_key :order_reviews, :users, column: :updated_by_id
  end
end
