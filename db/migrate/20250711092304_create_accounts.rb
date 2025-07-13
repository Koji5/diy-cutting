class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :account_type, null: false, default: 0 

      t.timestamps
    end
  end
end
