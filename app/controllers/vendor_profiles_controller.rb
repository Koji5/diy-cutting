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
      create_address_from_vendor_profile if params.dig(:vendor_profile, :add_flag) == "1"
      render_account_dashboard
    else
      flash[:alert] = @vendor_profile.errors.full_messages
      render_flash_and_replace(
          flash: flash
      )
    end
  end

  def edit
    @account = Current.account
    @vendor_profile = Current.account.vendor_profile
    @prefectures = MPrefecture.all.order(:code)
    @cities = MCity.where(prefecture_code: @vendor_profile.office_prefecture_code)
                .select(:code, :name_ja).order(:code, :name_ja)
    @bank_name      = MBank.find_by(code: @vendor_profile.bank_code)&.name
    @branch_name    = MBranch.find_by(bank_code: @vendor_profile.bank_code, code: @vendor_profile.branch_code)&.name

    render_flash_and_replace_main(
      template: "vendor_profiles/edit",
      assigns: {
        account: @account,
        vendor_profile: @vendor_profile,
        prefectures: @prefectures,
        cities: @cities,
        bank_name: @bank_name,
        branch_name: @branch_name
      }
    )
  end

  def update
    @vendor_profile = Current.account.vendor_profile
    if @vendor_profile.update(vendor_profile_params)
      flash[:notice] = "業者様プロフィールを更新しました。"
      create_address_from_vendor_profile if params.dig(:vendor_profile, :add_flag) == "1"
      render_account_dashboard
    else
      flash[:alert] = @vendor_profile.errors.full_messages
      render_flash_and_replace(
          flash: flash
      )
    end
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
      :office_name_kana,
      :bank_code,
      :branch_code
    )
  end

  def create_address_from_vendor_profile
    vp = params.require(:vendor_profile)

    @address = Current.account.addresses.build(
      postal_code:       vp[:office_postal_code].to_s.strip,
      prefecture_code:   vp[:office_prefecture_code],
      city_code:         vp[:office_city_code],
      address_line:      vp[:office_address_line],
      name:              vp[:office_name],
      name_kana:         vp[:office_name_kana],
      phone_number:      vp[:office_phone_number],
      department:        vp[:office_department],
      label:             "自動追加",
      default_flag:      Current.account.addresses.none?
    )

    if @address.save
      flash[:notice] = Array(flash[:notice]).push("アドレス帳へ住所を追加しました。")
    else
      flash[:alert] = @address.errors.full_messages
      flash[:alert] = Array(flash[:alert]).push("アドレス帳への住所の追加に失敗しました。")
    end
  end
end
