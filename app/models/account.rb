class Account < ApplicationRecord
  belongs_to :user
  has_one :member_profile, dependent: :destroy
  has_many :parts, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_many :carts, dependent: :destroy
  #accepts_nested_attributes_for :user ← Account モデル側ではネストしない

  ROLE_BITS = {
    member:    1 << 0, # 0001 → 1
    vendor:    1 << 1, # 0010 → 2
    admin:     1 << 2, # 0100 → 4
    affiliate: 1 << 3  # 1000 → 8
  }

  enum :legal_type, { individual: 0, corporation: 1 }

  def has_role?(role)
    (role_flags & ROLE_BITS[role]) != 0
  end

  def has_role_in?(roles)
    roles.any? { |r| has_role?(r) }
  end

  def add_role(role)
    self.role_flags |= ROLE_BITS[role]
  end

  def remove_role(role)
    self.role_flags &= ~ROLE_BITS[role]
  end

  def clear_roles
    self.role_flags = 0
  end

  def role_names
    ROLE_BITS.keys.select { |r| has_role?(r) }
  end
end
