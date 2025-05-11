class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :timeoutable, :lockable
  # ------------------------------------------------------------
  # Enum: 役割
  # ------------------------------------------------------------
  # ActiveStorage の ActiveHash 版を使うなら外部クラスで管理してもOK
  enum :role, {
    member:    0,
    vendor:    1,
    admin:     2,
    affiliate: 3
  }

  # ------------------------------------------------------------
  # 関連
  # ------------------------------------------------------------
  # 1:1 詳細テーブル（ポリモーフィック）
  belongs_to :detail, polymorphic: true

  # 自己参照 (作成者／更新者／削除者)
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true
  belongs_to :deleted_by, class_name: 'User', optional: true

  # ------------------------------------------------------------
  # バリデーション
  # ------------------------------------------------------------
  validates :public_uid, presence: true, uniqueness: true, length: { maximum: 32 }
  validates :email,      presence: true, uniqueness: true,
                         format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :encrypted_password, presence: true
  validates :role,       presence: true
  validates :detail_type, presence: true
  validates :detail_id,   presence: true
  # validates :login_failed_count, numericality: { greater_than_or_equal_to: 0 }

  # ------------------------------------------------------------
  # スコープ
  # ------------------------------------------------------------
  scope :active,   -> { where(deleted_flag: false) }
  scope :inactive, -> { where(deleted_flag: true)  }

  # ------------------------------------------------------------
  # コールバック例
  # ------------------------------------------------------------
  before_validation :ensure_public_uid, on: :create

  # ------------------------------------------------------------
  # インスタンスメソッド
  # ------------------------------------------------------------

  # 連続失敗回数をインクリメントし、閾値でロックする場合などに利用
  def register_failed_login!
    increment!(:failed_attempts)
    update!(locked_at: Time.current) if failed_attempts >= Devise.maximum_attempts
  end

  # 成功したらリセット
  def reset_failed_login!
    update!(failed_attempts: 0)
  end

  # ----------------------------------------
  # クラスメソッド
  # ----------------------------------------
  class << self
    # public_uid 生成などを一元管理
    def generate_public_uid
      SecureRandom.urlsafe_base64(24) # 32 文字未満
    end
  end

  private

  # `public_uid` が空の場合のみ自動採番
  def ensure_public_uid
    self.public_uid ||= self.class.generate_public_uid
  end

  # ----------------------------------------
  # TODO
  # ----------------------------------------

  # Devise を使う
  ## devise :database_authenticatable, :trackable, :validatable などを先頭に追加し、
  ## ncrypted_password ではなく Devise のカラム (password, password_confirmation) を使う構成に切り替えます

  # パスワード有効期限
  ## password_expires_at をチェックする validate :password_not_expired を追加するか、Devise の :timeoutable を拡張

  # ActiveHash で role 一覧を切り出す
  ## enum は残しつつ、RoleType クラスを作成して ActiveHash::Base で管理すると国際化や表示名の切り替えが楽

  # FactoryBot
  ## ruby\nFactoryBot.define do\n factory :user do\n public_uid { SecureRandom.urlsafe_base64(24) }\n email { Faker::Internet.email }\n encrypted_password { Devise::Encryptor.digest(User, 'password') }\n role { :member }\n association :detail, factory: :member_detail\n end\nend\n
end
