class Members::RegistrationsController < Devise::RegistrationsController

  before_action :store_affiliate_uid, only: :new
  before_action :populate_shipping_attrs, only: :edit

  def new
    session.delete(:affiliate_user_id) if params[:uid].blank?
    build_resource(role: :member)          # ← 最初から role を member に
    resource.build_member_detail if resource.member_detail.blank?         # ← 入力欄が出るよう関連を作成
    resource.member_detail.registered_affiliate_id =
      session[:affiliate_user_id]
    respond_with resource
  end

  def create
    super do |user|
      # ---------- アフィリエイト紐付け ----------
      if session[:affiliate_user_id].present?
        user.member_detail.update!(
          registered_affiliate_id: session.delete(:affiliate_user_id)
        )
      end
      # ---------- デフォルト送付先住所の自動登録 ----------
      if user.persisted? && user.member?
        save_default_shipping_address(user)
      end
    end
  end

  def update
    super do |user|
      save_default_shipping_address(user) if user.member?
    end
  end

  private

  def save_default_shipping_address(user)
    detail = user.member_detail

    # shipping_* が空なら billing_* をコピー
    postal_code     = detail.shipping_postal_code.presence     || detail.billing_postal_code
    prefecture_code = detail.shipping_prefecture_code.presence || detail.billing_prefecture_code
    city_code       = detail.shipping_city_code.presence       || detail.billing_city_code
    address_line    = detail.shipping_address_line.presence    || detail.billing_address_line
    phone_number    = detail.shipping_phone_number.presence    || detail.billing_phone_number
    department     = detail.shipping_department.presence     || detail.billing_department

    MemberShippingAddress.upsert(
      {
        member_id:       user.id,
        label:           'デフォルト',
        recipient_name:  detail.legal_name.presence || detail.nickname,
        postal_code:     postal_code,
        prefecture_code: prefecture_code,
        city_code:       city_code,
        address_line:    address_line,
        department:      department,
        phone_number:    phone_number,
        is_default:      true,
        created_by_id:   user.id,
        updated_by_id:   user.id
      },
      unique_by: :uq_member_default_address   # ★ インデックス名を指定
    )
  end

  def sign_up_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      member_detail_attributes: detail_permitted
    ).merge(role: :member)
  end

  def account_update_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :current_password,
      member_detail_attributes: detail_permitted
    )
  end

  def detail_permitted
    %i[
      id
      nickname icon_url
      legal_type legal_name legal_name_kana
      birthday gender
      billing_postal_code billing_prefecture_code billing_city_code
      billing_address_line billing_department billing_phone_number
      registered_affiliate_id
      shipping_postal_code shipping_prefecture_code shipping_city_code
      shipping_address_line shipping_department shipping_phone_number
    ]
  end

  def store_affiliate_uid
    uid = params[:uid]
    return unless uid.present?

    # public_uid が一致し、ロールがアフィリエイトのユーザーだけを対象
    if (affiliate = User.find_by(public_uid: uid))&.affiliate?
      session[:affiliate_user_id] = affiliate.id
    end
  end

  # -----------------------------------------------
  # 編集フォーム初期表示用: shipping_* 仮想属性を埋める
  # -----------------------------------------------
  def populate_shipping_attrs
    return unless resource.member?

    detail = resource.member_detail
    addr   = detail.shipping_addresses.find_by(is_default: true)
    return unless addr

    # ---------- 請求先を仮想属性に ----------
    detail.billing_postal_code     ||= detail.billing_postal_code
    detail.billing_prefecture_code ||= detail.billing_prefecture_code
    detail.billing_city_code       ||= detail.billing_city_code
    detail.billing_address_line    ||= detail.billing_address_line
    detail.billing_department      ||= detail.billing_department
    detail.billing_phone_number    ||= detail.billing_phone_number

    # ---------- 送付先（デフォルト） ----------
    detail.shipping_postal_code     = addr.postal_code
    detail.shipping_prefecture_code = addr.prefecture_code
    detail.shipping_city_code       = addr.city_code
    detail.shipping_address_line    = addr.address_line
    detail.shipping_department      = addr.department
    detail.shipping_phone_number    = addr.phone_number
  end

end
