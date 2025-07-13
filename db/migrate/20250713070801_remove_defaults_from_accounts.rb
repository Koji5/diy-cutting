class RemoveDefaultsFromAccounts < ActiveRecord::Migration[8.0]
  def change
    change_column_default :accounts, :legal_type, from: 0, to: nil
    change_column_default :accounts, :name, from: "", to: nil
  end
end
