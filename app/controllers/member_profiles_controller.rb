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
      flash[:notice] = "プロフィールを登録しました。"
      render_account_dashboard
    else
      flash[:alert] = @member_profile.errors.full_messages
      render_flash_and_replace(
          flash: flash
      )
    end
  end

  def edit
    # 未実装
    #@member_profile = Current.account.member_profile
  end

  def update
    # 未実装
    #@member_profile = Current.account.member_profile
    #if @member_profile.update(member_profile_params)
    #  redirect_to account_path, notice: "プロフィールを更新しました。"
    #else
    #  render :edit, status: :unprocessable_entity
    #end
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
