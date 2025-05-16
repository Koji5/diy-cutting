class Members::RegistrationsController < Devise::RegistrationsController
  def new
    build_resource                                              # Devise が @user を生成
    resource.member_detail_attributes = {} 
    respond_with resource
  end

  private

  def sign_up_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      detail_attributes: member_detail_permitted         # ←★ ネスト属性で許可
    ).merge(role: :member)
  end

  def account_update_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :current_password,
      detail_attributes: member_detail_permitted
    )
  end

  def member_detail_permitted
    %i[
      nickname icon_url
      legal_type legal_name legal_name_kana
      birthday gender
      billing_postal_code
      billing_prefecture_code billing_city_code billing_address_line
      billing_department billing_phone_number
    ]
  end
end
