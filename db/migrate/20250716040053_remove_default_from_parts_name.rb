class RemoveDefaultFromPartsName < ActiveRecord::Migration[8.0]
  def change
    change_column_default :parts, :name, from: '', to: nil
  end
end
