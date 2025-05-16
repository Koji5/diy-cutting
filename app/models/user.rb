class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :timeoutable, :lockable

  enum :role, { member: 0, vendor: 1, admin: 2, affiliate: 3 }

  # polymorphic 1:1
  belongs_to :detail, polymorphic: true, autosave: true
  accepts_nested_attributes_for :detail

  # callbacks
  before_validation :ensure_public_uid,        on: :create
  before_validation :build_detail_for_member,  on: :create

  validates :public_uid, presence: true, uniqueness: true, length: { maximum: 32 }
  validates :email,      presence: true, uniqueness: true,
                         format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role,   presence: true
  validates :detail, presence: true

  private

  def ensure_public_uid = self.public_uid ||= SecureRandom.urlsafe_base64(24)

  def build_detail_for_member
    return unless member? && detail.nil?               # safety
    self.detail = MemberDetail.new(role: :member)
  end
end
