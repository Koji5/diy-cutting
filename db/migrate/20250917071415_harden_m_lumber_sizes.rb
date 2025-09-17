class HardenMLumberSizes < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!  # 部分的に並行INDEXを使うため

  TABLE = :m_lumber_sizes

  def up
    # 1) 欄の追加（存在しない場合のみ）
    add_column TABLE, :deleted_at,   :timestamp, precision: 6 unless column_exists?(TABLE, :deleted_at)
    add_column TABLE, :deleted_by_id, :bigint unless column_exists?(TABLE, :deleted_by_id)
    add_column TABLE, :created_by_id, :bigint unless column_exists?(TABLE, :created_by_id)
    add_column TABLE, :updated_by_id, :bigint unless column_exists?(TABLE, :updated_by_id)

    # 2) code列の追加（主キー化の準備）
    unless column_exists?(TABLE, :code)
      add_column TABLE, :code, :string, limit: 32
      # 既存行へcodeを一括付与（例： "38x89" のように「幅x厚」を整数化して生成）
      # 小数を扱う設計の場合は丸め/書式を要検討。ここでは小数なし前提。
      execute <<~SQL.squish
        UPDATE #{TABLE}
           SET code = (width_mm::int)::text || 'x' || (thickness_mm::int)::text
         WHERE code IS NULL OR code = '';
      SQL
      # codeの重複を検査（重複があると主キー化に失敗する）
      duplicates = execute(<<~SQL).to_a
        SELECT code, COUNT(*) c FROM #{TABLE}
         GROUP BY code HAVING COUNT(*) > 1;
      SQL
      if duplicates.any?
        raise "❌ m_lumber_sizes.code に重複があります: #{duplicates.inspect}"
      end
      # 先にNOT NULL制約
      change_column_null TABLE, :code, false
      # 先に一意インデックス（並行）を作成しておくと安全
      add_index TABLE, :code, unique: true, algorithm: :concurrently, name: :index_m_lumber_sizes_on_code_unique unless index_exists?(TABLE, :code, unique: true, name: :index_m_lumber_sizes_on_code_unique)
    end

    # 3) 既存のPRIMARY KEY(id) → codeへ切替
    #    Postgresは同時に2つのPRIMARY KEYを持てないため、順序に注意
    execute <<~SQL
      ALTER TABLE #{TABLE} DROP CONSTRAINT IF EXISTS #{TABLE}_pkey;
      ALTER TABLE #{TABLE} ADD CONSTRAINT #{TABLE}_pkey PRIMARY KEY (code);
    SQL

    # 4) id列の削除（不要なら）
    if column_exists?(TABLE, :id)
      # 参照制約が無いことを確認したうえで削除
      remove_column TABLE, :id
    end

    # 5) 操作ユーザー系のINDEX（並行）
    add_index TABLE, :created_by_id, algorithm: :concurrently unless index_exists?(TABLE, :created_by_id)
    add_index TABLE, :updated_by_id, algorithm: :concurrently unless index_exists?(TABLE, :updated_by_id)
    add_index TABLE, :deleted_by_id, algorithm: :concurrently unless index_exists?(TABLE, :deleted_by_id)

    # 6) 外部キー（参照先テーブルは環境に合わせて変更）
    # ここでは users(id) を参照。存在しない/名称違いなら accounts(id) などに置換してください。
    add_foreign_key TABLE, :users, column: :created_by_id, validate: false unless foreign_key_exists?(TABLE, :users, column: :created_by_id)
    add_foreign_key TABLE, :users, column: :updated_by_id, validate: false unless foreign_key_exists?(TABLE, :users, column: :updated_by_id)
    add_foreign_key TABLE, :users, column: :deleted_by_id, validate: false unless foreign_key_exists?(TABLE, :users, column: :deleted_by_id)

    # 段階的に検証ON（大規模テーブル向け）
    validate_foreign_key TABLE, :users, column: :created_by_id if foreign_key_exists?(TABLE, :users, column: :created_by_id)
    validate_foreign_key TABLE, :users, column: :updated_by_id if foreign_key_exists?(TABLE, :users, column: :updated_by_id)
    validate_foreign_key TABLE, :users, column: :deleted_by_id if foreign_key_exists?(TABLE, :users, column: :deleted_by_id)
  end

  def down
    # 外部キーの解除
    remove_foreign_key TABLE, column: :created_by_id if foreign_key_exists?(TABLE, :users, column: :created_by_id)
    remove_foreign_key TABLE, column: :updated_by_id if foreign_key_exists?(TABLE, :users, column: :updated_by_id)
    remove_foreign_key TABLE, column: :deleted_by_id if foreign_key_exists?(TABLE, :users, column: :deleted_by_id)

    # INDEXの削除
    remove_index TABLE, :created_by_id if index_exists?(TABLE, :created_by_id)
    remove_index TABLE, :updated_by_id if index_exists?(TABLE, :updated_by_id)
    remove_index TABLE, :deleted_by_id if index_exists?(TABLE, :deleted_by_id)
    remove_index TABLE, name: :index_m_lumber_sizes_on_code_unique if index_exists?(TABLE, name: :index_m_lumber_sizes_on_code_unique)

    # PKをidに戻すため、idを復活させる（簡易実装）
    unless column_exists?(TABLE, :id)
      add_column TABLE, :id, :bigint
      execute "CREATE SEQUENCE IF NOT EXISTS m_lumber_sizes_id_seq OWNED BY #{TABLE}.id;"
      execute "UPDATE #{TABLE} SET id = nextval('m_lumber_sizes_id_seq');"
      execute "ALTER TABLE #{TABLE} ALTER COLUMN id SET NOT NULL;"
    end

    execute <<~SQL
      ALTER TABLE #{TABLE} DROP CONSTRAINT IF EXISTS #{TABLE}_pkey;
      ALTER TABLE #{TABLE} ADD CONSTRAINT #{TABLE}_pkey PRIMARY KEY (id);
    SQL

    # code列は残す（必要なら以下で削除）
    # remove_column TABLE, :code if column_exists?(TABLE, :code)

    # 追加カラムの削除（必要に応じて）
    # remove_column TABLE, :deleted_at   if column_exists?(TABLE, :deleted_at)
    # remove_column TABLE, :deleted_by_id if column_exists?(TABLE, :deleted_by_id)
    # remove_column TABLE, :created_by_id if column_exists?(TABLE, :created_by_id)
    # remove_column TABLE, :updated_by_id if column_exists?(TABLE, :updated_by_id)
  end
end
