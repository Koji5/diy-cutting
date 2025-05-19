class ReplaceRoleWithMembershipPlanOnMemberDetails < ActiveRecord::Migration[8.0]
  def up
    # ① 新カラム追加：0=free をデフォルトに固定
    add_column :member_details, :membership_plan, :integer,
              default: 0, null: false

    # ② 既存レコードを一括 0 に更新（SQL の方が高速）
    execute <<~SQL
      UPDATE member_details SET membership_plan = 0;
    SQL

    # ③ 旧カラム削除
    remove_column :member_details, :role
  end
end