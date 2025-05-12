class FixLengthOfPrefectureAndCityCodes < ActiveRecord::Migration[8.0]
  def change
    # ① 都道府県コードを char(2) ではなく varchar(2) に
    change_column :m_prefectures, :code, :string, limit: 2
    change_column :m_cities,      :prefecture_code, :string, limit: 2

    # ② 市区町村コードを varchar(5)
    change_column :m_cities, :code, :string, limit: 5

    # ③ CHECK 制約を付け直し（任意だが推奨）
    execute <<~SQL
      ALTER TABLE m_prefectures
        DROP CONSTRAINT IF EXISTS m_prefectures_code_chk,
        ADD  CONSTRAINT m_prefectures_code_chk
              CHECK (code BETWEEN '01' AND '47');

      ALTER TABLE m_cities
        ADD CONSTRAINT m_cities_code_len_chk
              CHECK (char_length(code) = 5);
    SQL
  end
end