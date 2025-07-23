class Address < ApplicationRecord
  belongs_to :account
  belongs_to :prefecture, class_name: "MPrefecture", foreign_key: "prefecture_code", primary_key: "code", optional: true
  belongs_to :city, class_name: "MCity", foreign_key: "city_code", primary_key: "code", optional: true

  before_save :unset_existing_default, if: :default_flag?

  private

  def only_one_default_per_account
    existing = Address.where(account_id: account_id, default_flag: true)

    # 新規作成時 or 自分以外にすでにtrueの行がある
    if persisted?
      existing = existing.where.not(id: id)
    end

    if existing.exists?
      errors.add(:default_flag, "は1つのアカウントにつき1件までです")
    end
  end

  def unset_existing_default
    self.class.where(account_id: account_id, default_flag: true)
              .where.not(id: id)
              .update_all(default_flag: false)
  end

end
