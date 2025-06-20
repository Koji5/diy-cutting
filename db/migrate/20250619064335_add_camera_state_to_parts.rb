class AddCameraStateToParts < ActiveRecord::Migration[8.0]
  def change
    add_column :parts, :camera_state, :jsonb
  end
end
