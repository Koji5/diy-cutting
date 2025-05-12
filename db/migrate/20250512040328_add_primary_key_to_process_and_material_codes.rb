class AddPrimaryKeyToProcessAndMaterialCodes < ActiveRecord::Migration[8.0]
  def change
    # m_process_types
    execute <<~SQL
      ALTER TABLE m_process_types
        ADD CONSTRAINT m_process_types_pkey PRIMARY KEY (code);
    SQL

    # m_materials
    execute <<~SQL
      ALTER TABLE m_materials
        ADD CONSTRAINT m_materials_pkey PRIMARY KEY (code);
    SQL
  end
end
