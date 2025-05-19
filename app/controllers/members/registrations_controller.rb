class Members::RegistrationsController < Devise::RegistrationsController

  before_action :store_affiliate_uid, only: :new

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
      if session[:affiliate_user_id].present?
        user.member_detail.update!(
          registered_affiliate_id: session.delete(:affiliate_user_id)
        )
      end
    end
  end
  private

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
      nickname icon_url
      legal_type legal_name legal_name_kana
      birthday gender
      billing_postal_code billing_prefecture_code billing_city_code
      billing_address_line billing_department billing_phone_number
      registered_affiliate_id
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
end
