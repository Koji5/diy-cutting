class MemberShippingAddress < ApplicationRecord
  # ------------------------------------------------------------
  # Associations
  # ------------------------------------------------------------
  belongs_to :member_detail,
             class_name:  'MemberDetail',
             foreign_key: :member_id,
             primary_key: :user_id,
             inverse_of:  :shipping_addresses

  belongs_to :prefecture,
             class_name:  'MPrefecture',
             foreign_key: :prefecture_code,
             primary_key: :code

  belongs_to :city,
             class_name:  'MCity',
             foreign_key: :city_code,
             primary_key: :code

  # ------------------------------------------------------------
  # Validations
  # ------------------------------------------------------------
  with_options presence: true do
    validates :member_id
    validates :recipient_name, length: { maximum: 100 }
    validates :postal_code,    length: { maximum: 8 }
    validates :prefecture_code, length: { is: 2 }
    validates :city_code,       length: { is: 5 }
    validates :address_line,    length: { maximum: 200 }
  end

  validates :label,        length: { maximum: 50 }, allow_blank: true
  validates :phone_number, length: { maximum: 20 }, allow_blank: true
  validates :is_default,   inclusion: { in: [true, false] }

  # アプリ側でも “会員ごとに default は 1 件” を担保
  validates :member_id,
            uniqueness: { conditions: -> { where(is_default: true) },
                          message: 'はデフォルト住所が重複しています' },
            if: :is_default?
  validates :department, length: { maximum: 100 }, allow_blank: true
  # ------------------------------------------------------------
  # Callbacks
  # ------------------------------------------------------------
  # デフォルト変更時に他を false にする
  before_save :unset_previous_default, if: :will_save_change_to_is_default?

  private

  def unset_previous_default
    return unless is_default?

    self.class.where(member_id: member_id, is_default: true)
              .where.not(id: id)
              .update_all(is_default: false)
  end
end
