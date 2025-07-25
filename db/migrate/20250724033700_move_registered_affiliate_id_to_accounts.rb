class MoveRegisteredAffiliateIdToAccounts < ActiveRecord::Migration[8.0]
  def change
    # accountsテーブルにカラム追加（外部キー付き）
    add_reference :accounts, :registered_affiliate, foreign_key: { to_table: :accounts }

    # member_profilesテーブルからカラム削除
    remove_reference :member_profiles, :registered_affiliate, foreign_key: { to_table: :accounts }
  end
end
