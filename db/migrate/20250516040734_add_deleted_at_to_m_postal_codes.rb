# db/migrate/xxxxxx_add_deleted_at_to_m_postal_codes.rb
class AddDeletedAtToMPostalCodes < ActiveRecord::Migration[8.0]
  def change
    add_column :m_postal_codes, :deleted_at, :timestamptz
  end
end
