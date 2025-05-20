# app/controllers/vendors/registrations_controller.rb
class Vendors::RegistrationsController < Devise::RegistrationsController
  def new
    build_resource(role: :vendor)
    resource.build_vendor_detail if resource.vendor_detail.blank?
    respond_with resource
  end

  def create
    build_resource(sign_up_params.merge(role: :vendor))
    resource.build_vendor_detail(vendor_detail_params)

    if resource.save
      sign_up(resource_name, resource)
      redirect_to root_path, notice: "ベンダー登録が完了しました"
    else
      clean_up_passwords resource
      render :new, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.require(:user)
          .permit(:email, :password, :password_confirmation)
  end

  def vendor_detail_params
    params.require(:user)
          .require(:vendor_detail_attributes)
          .permit(:nickname, :profile_icon_url,
                  :vendor_name, :vendor_name_kana, :invoice_number,
                  :contact_person_name, :contact_person_kana,
                  :contact_phone_number,
                  :contact_person_name, :contact_person_kana,
                  :contact_phone_number,
                  :office_postal_code, :office_prefecture_code,
                  :office_city_code, :office_address_line,
                  :office_phone_number,
                  :bank_name, :account_type, :account_number, :account_name)
  end
end
