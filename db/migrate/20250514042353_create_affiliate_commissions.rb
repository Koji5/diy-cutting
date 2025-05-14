class CreateAffiliateCommissions < ActiveRecord::Migration[8.0]
  def change
    create_table :affiliate_commissions do |t|
      # -------- relations --------
      t.references :affiliate_user, null: false,
                                    foreign_key: { to_table: :users },
                                    index: true

      t.references :referred_user,  null: false,
                                    foreign_key: { to_table: :users }

      t.references :order,         null: false,
                                    foreign_key: true
      # -------- amounts --------
      t.decimal :order_amount,      precision: 18, scale: 4,
                                    null: false, default: 0
      t.decimal :rate_pct,          precision: 5,  scale: 2,
                                    null: false, default: 0
      t.decimal :commission_amount, precision: 18, scale: 4,
                                    null: false, default: 0

      # -------- payment flag --------
      t.boolean  :paid_flag,  null: false, default: false
      t.datetime :paid_at

      # -------- audit --------
      t.boolean  :deleted_flag, null: false, default: false
      t.datetime :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # 一意：1 注文につき 1 レコード
    add_index :affiliate_commissions, :order_id,
              unique: true, name: :uq_aff_comm_order

    # ----- CHECK 制約 -----
    # 金額は 0 以上
    add_check_constraint :affiliate_commissions,
                         'commission_amount >= 0',
                         name: :chk_aff_comm_amount_non_negative

    # paid_flag=true → paid_at NOT NULL
    add_check_constraint :affiliate_commissions,
                         "(NOT paid_flag) OR paid_at IS NOT NULL",
                         name: :chk_aff_comm_paid_consistency
  end
end
