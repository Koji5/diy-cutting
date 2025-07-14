class User < ApplicationRecord
  has_one :account, dependent: :destroy
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :lockable, :validatable

  has_many :parts,
           dependent: :destroy,
           inverse_of: :user
  has_many :recipes, dependent: :destroy
  has_many :carts, dependent: :destroy

  #accepts_nested_attributes_for :account
end
