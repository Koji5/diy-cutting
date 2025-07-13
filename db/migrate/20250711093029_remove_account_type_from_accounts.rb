class RemoveAccountTypeFromAccounts < ActiveRecord::Migration[8.0]
  def change
    remove_column :accounts, :account_type, :integer
  end
end
