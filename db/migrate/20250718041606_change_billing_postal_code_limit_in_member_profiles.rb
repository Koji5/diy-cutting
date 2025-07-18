class ChangeBillingPostalCodeLimitInMemberProfiles < ActiveRecord::Migration[8.0]
  def change
    change_column :member_profiles, :billing_postal_code, :string, limit: 7
  end
end
