# db/migrate/XXXXXXXXXX_create_affiliate_recipe_commissions.rb
class CreateAffiliateRecipeCommissions < ActiveRecord::Migration[8.0]
  def change
    create_table :affiliate_recipe_commissions do |t|
      t.references :original_user,   null: false, foreign_key: { to_table: :users }
      t.references :fork_user,       null: false, foreign_key: { to_table: :users }
      t.references :recipe_snapshot, null: false, foreign_key: true
      t.references :order,           null: false, foreign_key: true

      t.bigint    :commission_cents, null: false
      t.boolean   :settled_flag,     null: false, default: false
      t.datetime  :settled_at

      # 監査系 7 列
      t.timestamps                   null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.references :created_by
      t.references :updated_by
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by
    end

    # 重複付与防止：同一注文×同一 snapshot で 1 行だけ
    add_index :affiliate_recipe_commissions,
              %i[order_id recipe_snapshot_id],
              unique: true,
              name: :uniq_commission_per_order_and_snapshot

    add_index :affiliate_recipe_commissions,
              %i[original_user_id settled_flag],
              name: :idx_commission_settlement
  end
end
