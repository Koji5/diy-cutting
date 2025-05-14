class CreateQuoteRequestComments < ActiveRecord::Migration[8.0]
  def change
    create_table :quote_request_comments do |t|
      t.references :quote_request, null: false, foreign_key: true, index: true
      t.references :parent,        foreign_key: { to_table: :quote_request_comments }, index: true

      # polymorphic author
      t.string  :author_type, null: false, limit: 20
      t.bigint  :author_id,   null: false
      t.index   [:author_type, :author_id], name: :idx_qr_comments_author_polymorphic

      t.text    :body, null: false

      # meta / audit
      t.boolean    :deleted_flag,  null: false, default: false
      t.datetime   :deleted_at
      t.bigint     :deleted_by_id, index: true
      t.bigint     :created_by_id, index: true
      t.bigint     :updated_by_id, index: true
      t.timestamps  default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # FK for audit columns
    add_foreign_key :quote_request_comments, :users, column: :created_by_id
    add_foreign_key :quote_request_comments, :users, column: :updated_by_id
    add_foreign_key :quote_request_comments, :users, column: :deleted_by_id

    # CHECK constraint for valid author_type
    execute <<~SQL
      ALTER TABLE quote_request_comments
        ADD CONSTRAINT chk_qr_comments_author_type
          CHECK (author_type IN (
            'MemberDetail','VendorDetail','AdminDetail','AffiliateDetail'
          ));
    SQL
  end
end
