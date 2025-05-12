class AddPrimaryKeyToMemberDetails < ActiveRecord::Migration[8.0]
  def change
    execute "ALTER TABLE member_details ADD PRIMARY KEY (user_id);"
  end
end
