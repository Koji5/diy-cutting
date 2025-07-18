class AddUniqueDefaultAddressPerAccount < ActiveRecord::Migration[8.0]
  def change
    add_index :addresses, :account_id,
      unique: true,
      where: "default_flag = true",
      name: "uq_account_default_address"
  end
end
