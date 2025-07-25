class UpdateAddressesAndMemberProfiles < ActiveRecord::Migration[8.0]
  def change
    # addressesテーブル
    rename_column :addresses, :recipient_name, :name
    add_column :addresses, :name_kana, :string, limit: 100
    add_column :addresses, :department, :string, limit: 100

    # member_profilesテーブル
    rename_column :member_profiles, :billing_person_name, :billing_name
    add_column :member_profiles, :billing_name_kana, :string, limit: 100
  end
end
