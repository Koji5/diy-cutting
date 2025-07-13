class AddRoleFlagsToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :role_flags, :integer, null: false, default: 0
  end
end
