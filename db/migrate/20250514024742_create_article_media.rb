class CreateArticleMedia < ActiveRecord::Migration[8.0]
  def change
    create_table :article_media do |t|
      t.references :article,  null: false, foreign_key: true, index: true

      t.integer  :media_type, null: false, limit: 2             # smallint
      t.string   :file_url,   null: false, limit: 500
      t.string   :caption,    limit: 150
      t.integer  :position,   limit: 2                          # smallint
      t.jsonb    :meta_json,  null: true,  default: '{}'

      # メタ・論理削除列
      t.boolean     :deleted_flag,  null: false, default: false
      t.datetime    :deleted_at
      t.bigint      :deleted_by_id, index: true
      t.bigint      :created_by_id, index: true
      t.bigint      :updated_by_id, index: true
      t.timestamps  null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end

    # JSONB は全文検索しない前提で GIN index は付けていません
    # （必要になった時に `add_index :article_media, :meta_json, using: :gin`）。
  end
end
