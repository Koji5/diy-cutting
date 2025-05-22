class DropQuoteRequestComments < ActiveRecord::Migration[8.0]
  def up
    drop_table :quote_request_comments, force: :cascade if table_exists?(:quote_request_comments)
  end
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end