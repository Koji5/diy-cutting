# db/migrate/XXXXXXXXXXXXXX_add_camera_state_json_to_board_parts.rb
class AddCameraStateJsonToBoardParts < ActiveRecord::Migration[8.0]
  def change
    add_column :board_parts, :camera_state_json, :jsonb, default: {}
  end
end
