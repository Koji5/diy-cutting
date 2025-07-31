class VendorProfile < ApplicationRecord
  belongs_to :account

  validates :bank_code, presence: true
  validates :branch_code, presence: true

  validate :bank_code_must_exist
  validate :branch_code_must_exist_within_bank

  def bank_code_must_exist
    errors.add(:bank_code, "が存在しません") unless MBank.exists?(code: bank_code)
  end

  def branch_code_must_exist_within_bank
    return if bank_code.blank? || branch_code.blank?
    unless MBranch.exists?(bank_code: bank_code, code: branch_code)
      errors.add(:branch_code, "が該当銀行に存在しません")
    end
  end
end
