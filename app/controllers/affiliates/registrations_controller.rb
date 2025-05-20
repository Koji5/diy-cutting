class Affiliates::RegistrationsController < Devise::RegistrationsController

  def new
    build_resource(role: :affiliate)
    resource.build_affiliate_detail if resource.affiliate_detail.blank?
    respond_with resource
  end

  def create
    build_resource(sign_up_params.merge(role: :affiliate))
    resource.build_affiliate_detail(affiliate_detail_params)

    if resource.save
      sign_up(resource_name, resource)
      redirect_to root_path, notice: "アフィリエイト登録が完了しました"
    else
      clean_up_passwords resource
      render :new, status: :unprocessable_entity
    end
  end

  private

  # ==== Strong Parameters ====
  def sign_up_params
    params.require(:user)
          .permit(:email, :password, :password_confirmation)
  end

  def affiliate_detail_params
    params.require(:user)
          .require(:affiliate_detail_attributes)
          .permit(:name, :name_kana,
                  :postal_code, :prefecture_code, :city_code, :address_line,
                  :phone_number, :invoice_number,
                  :bank_name, :account_type, :account_number, :account_holder)
  end
end
