class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :timeoutable, :lockable

  enum :role, { member: 0, vendor: 1, admin: 2, affiliate: 3 }

  has_one :member_detail,    dependent: :destroy
  has_one :vendor_detail,    dependent: :destroy
  has_one :admin_detail,     dependent: :destroy
  has_one :affiliate_detail, dependent: :destroy
  accepts_nested_attributes_for :member_detail
  accepts_nested_attributes_for :vendor_detail
  accepts_nested_attributes_for :admin_detail
  accepts_nested_attributes_for :affiliate_detail
  has_secure_token :public_uid

  # ロール毎に “詳細テーブル” と “候補カラム” をマッピング
  DISPLAY_NAME_MAP = {
    member:    { assoc: :member_detail,    cols: %i[nickname legal_name]  },
    vendor:    { assoc: :vendor_detail,    cols: %i[nickname vendor_name] },
    admin:     { assoc: :admin_detail,     cols: %i[nickname]          },
    affiliate: { assoc: :affiliate_detail, cols: %i[name]            }
  }.freeze

  # callbacks

  validates :public_uid, presence: true, uniqueness: true, length: { maximum: 32 }
  validates :email,      presence: true, uniqueness: true,
                         format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role,   presence: true

  # ----- 共通表示名 -----
  def display_name
    map = DISPLAY_NAME_MAP[role.to_sym]
    return email unless map                                  # 想定外ロール

    record = public_send(map[:assoc])                        # 例: member_detail
    return email unless record                               # nil セーフティ

    # 候補カラムを順番に探して最初に値が入っていたものを返す
    map[:cols].find { |c| record[c].present? }               # => シンボル or nil
         &.then { |c| record[c] } || email                   # 値が無ければ email
  end

end
