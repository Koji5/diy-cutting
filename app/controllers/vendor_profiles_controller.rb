class VendorProfilesController < ApplicationController
  include AccountDashboardRenderable

  def new
    @account = Current.account
    @vendor_profile = Current.account.build_vendor_profile
    @prefectures = MPrefecture.all.order(:code)
    render_flash_and_replace_main(
      template: "vendor_profiles/new",
      assigns: {
        account: @account,
        vendor_profile: @vendor_profile,
        prefectures: @prefectures
      }
    )
  end

  def create
    @vendor_profile = Current.account.build_vendor_profile(vendor_profile_params)
    if @vendor_profile.save
      flash[:notice] = "お客様プロフィールを登録しました。"
      render_account_dashboard
    else
      flash[:alert] = @vendor_profile.errors.full_messages
      render_flash_and_replace(
          flash: flash
      )
    end
  end

  def edit
  #  @account = Current.account
  #  @vendor_profile = Current.account.vendor_profile
  #  @prefectures = MPrefecture.all.order(:code)
  #  @cities = MCity.where(prefecture_code: @vendor_profile.billing_prefecture_code)
  #              .select(:code, :name_ja).order(:code, :name_ja)
  #  render_flash_and_replace_main(
  #    template: "vendor_profiles/edit",
  #    assigns: {
  #      account: @account,
  #      vendor_profile: @vendor_profile,
  #      prefectures: @prefectures,
  #      cities: @cities
  #    }
  #  )
  end

  def update
  #  @vendor_profile = Current.account.vendor_profile
  #  if @vendor_profile.update(vendor_profile_params)
  #    flash[:notice] = "お客様プロフィールを更新しました。"
  #    render_account_dashboard
  #  else
  #    flash[:alert] = @vendor_profile.errors.full_messages
  #    render_flash_and_replace(
  #        flash: flash
  #    )
  #  end
  end

  private

  def vendor_profile_params
    params.require(:vendor_profile).permit(
      :invoice_number,
      :contact_person_name,
      :contact_person_kana,
      :contact_phone_number,
      :office_postal_code,
      :office_prefecture_code,
      :office_city_code,
      :office_address_line,
      :office_department,
      :office_phone_number,
      :office_email,
      :description,
      :account_type,
      :account_number,
      :account_name,
      :office_name,
      :office_name_kanaL,
      :bank_code,
      :branch_code
    )
  end
end
