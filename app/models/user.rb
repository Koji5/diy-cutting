class User < ApplicationRecord
  has_one :account, dependent: :destroy
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :lockable, :validatable

  has_many :parts,
           dependent: :destroy,
           inverse_of: :user
  has_many :recipes, dependent: :destroy
  has_many :carts, dependent: :destroy

  accepts_nested_attributes_for :account

  private

  def password_required?
    # 新規作成時またはパスワードが明示的に変更されているときのみ true
    new_record? || password.present? || password_confirmation.present?
  end
end
