class RenameMBoardThicknessToMBoardThicknesses < ActiveRecord::Migration[8.0]
  def up
    # テーブル名を複数形へ
    rename_table :m_board_thickness, :m_board_thicknesses

    # （任意）インデックス名の体裁を整える
    if index_name_exists?(:m_board_thicknesses, "index_m_board_thickness_on_created_by_id")
      rename_index :m_board_thicknesses,
                   "index_m_board_thickness_on_created_by_id",
                   "index_m_board_thicknesses_on_created_by_id"
    end
    if index_name_exists?(:m_board_thicknesses, "index_m_board_thickness_on_updated_by_id")
      rename_index :m_board_thicknesses,
                   "index_m_board_thickness_on_updated_by_id",
                   "index_m_board_thicknesses_on_updated_by_id"
    end
    if index_name_exists?(:m_board_thicknesses, "index_m_board_thickness_on_deleted_by_id")
      rename_index :m_board_thicknesses,
                   "index_m_board_thickness_on_deleted_by_id",
                   "index_m_board_thicknesses_on_deleted_by_id"
    end

    # （任意）主キー制約名の体裁を整える
    begin
      execute <<~SQL
        ALTER TABLE m_board_thicknesses
        RENAME CONSTRAINT m_board_thickness_pkey TO m_board_thicknesses_pkey;
      SQL
    rescue ActiveRecord::StatementInvalid
      # 既に別名になっている／存在しない場合はスキップ
    end

    # 外部キー制約（fk_rails_xxxxx など）の名称は環境依存なので、原則そのままでOKです
  end

  def down
    # （任意）主キー制約名を戻す
    begin
      execute <<~SQL
        ALTER TABLE m_board_thicknesses
        RENAME CONSTRAINT m_board_thicknesses_pkey TO m_board_thickness_pkey;
      SQL
    rescue ActiveRecord::StatementInvalid
    end

    # （任意）インデックス名を戻す
    if index_name_exists?(:m_board_thicknesses, "index_m_board_thicknesses_on_created_by_id")
      rename_index :m_board_thicknesses,
                   "index_m_board_thicknesses_on_created_by_id",
                   "index_m_board_thickness_on_created_by_id"
    end
    if index_name_exists?(:m_board_thicknesses, "index_m_board_thicknesses_on_updated_by_id")
      rename_index :m_board_thicknesses,
                   "index_m_board_thicknesses_on_updated_by_id",
                   "index_m_board_thickness_on_updated_by_id"
    end
    if index_name_exists?(:m_board_thicknesses, "index_m_board_thicknesses_on_deleted_by_id")
      rename_index :m_board_thicknesses,
                   "index_m_board_thicknesses_on_deleted_by_id",
                   "index_m_board_thickness_on_deleted_by_id"
    end

    # テーブル名を戻す
    rename_table :m_board_thicknesses, :m_board_thickness
  end
end
