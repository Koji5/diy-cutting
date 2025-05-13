class AddPrimaryKeyToMCategories < ActiveRecord::Migration[8.0]
  def change
    # 既に一意インデックスがあるので、そのまま PK を追加するだけ
    execute "ALTER TABLE m_categories ADD PRIMARY KEY (code);"
  end
end
