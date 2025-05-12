class AddUniqueIndexToMAuthoritiesCode < ActiveRecord::Migration[8.0]
  def change
    # code 列が PK ならこの行で OK、PK でなくても UNIQUE になれば FK が張れる
    add_index :m_authorities, :code, unique: true
  end
end