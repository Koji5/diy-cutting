class MemberProfilesController < ApplicationController
  def new
    @member_profile = MemberProfile.new
  end

  def create
    @member_profile = Current.account.build_member_profile(member_profile_params)
    if @member_profile.save
      redirect_to account_path, notice: "プロフィールを登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @member_profile = Current.account.member_profile
  end

  def update
    @member_profile = Current.account.member_profile
    if @member_profile.update(member_profile_params)
      redirect_to account_path, notice: "プロフィールを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def member_profile_params
    params.require(:member_profile).permit(
      :billing_postal_code,
      :billing_prefecture_code,
      :billing_city_code,
      :billing_address_line,
      :billing_department,
      :billing_phone_number
    )
  end
end
