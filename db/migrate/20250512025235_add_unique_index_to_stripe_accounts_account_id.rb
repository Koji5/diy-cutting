class AddUniqueIndexToStripeAccountsAccountId < ActiveRecord::Migration[8.0]
  def change
    remove_index :stripe_accounts, :stripe_account_id
    add_index    :stripe_accounts, :stripe_account_id, unique: true
  end
end