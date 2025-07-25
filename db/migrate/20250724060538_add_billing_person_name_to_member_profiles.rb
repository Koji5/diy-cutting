class AddBillingPersonNameToMemberProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :member_profiles, :billing_person_name, :string, limit: 100
  end
end
