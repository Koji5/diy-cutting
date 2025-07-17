class RenameUserIdToAccountIdInRecipes < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :recipes, column: :user_id
    rename_column :recipes, :user_id, :account_id
    #rename_index :recipes, "index_recipes_on_user_id", "index_recipes_on_account_id"
    add_foreign_key :recipes, :accounts, column: :account_id
  end
end
