class MemberProfilesController < ApplicationController
  include AccountDashboardRenderable

  def new
    @account = Current.account
    @member_profile = Current.account.build_member_profile
    @prefectures = MPrefecture.all.order(:code)
    render_flash_and_replace_main(
      template: "member_profiles/new",
      assigns: {
        account: @account,
        member_profile: @member_profile,
        prefectures: @prefectures
      }
    )
  end

  def create
    @member_profile = Current.account.build_member_profile(member_profile_params)
    if @member_profile.save
      flash[:notice] = "お客様プロフィールを登録しました。"
      render_account_dashboard
    else
      flash[:alert] = @member_profile.errors.full_messages
      render_flash_and_replace(
          flash: flash
      )
    end
  end

  def edit
    @account = Current.account
    @member_profile = Current.account.member_profile
    @prefectures = MPrefecture.all.order(:code)
    @cities = MCity.where(prefecture_code: @member_profile.billing_prefecture_code)
                .select(:code, :name_ja).order(:code, :name_ja)
    render_flash_and_replace_main(
      template: "member_profiles/edit",
      assigns: {
        account: @account,
        member_profile: @member_profile,
        prefectures: @prefectures,
        cities: @cities
      }
    )
  end

  def update
    @member_profile = Current.account.member_profile
    if @member_profile.update(member_profile_params)
      flash[:notice] = "お客様プロフィールを更新しました。"
      render_account_dashboard
    else
      flash[:alert] = @member_profile.errors.full_messages
      render_flash_and_replace(
          flash: flash
      )
    end
  end

  private

  def member_profile_params
    params.require(:member_profile).permit(
      :billing_name,
      :billing_name_kana,
      :billing_postal_code,
      :billing_prefecture_code,
      :billing_city_code,
      :billing_address_line,
      :billing_department,
      :billing_phone_number
    )
  end
end
