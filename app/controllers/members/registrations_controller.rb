class Members::RegistrationsController < Devise::RegistrationsController

  def new
    build_resource(role: :member)          # ← 最初から role を member に
    resource.prepare_member_detail         # ← 入力欄が出るよう関連を作成
    respond_with resource
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
    ]
  end
end
