class MemberProfilesController < ApplicationController
  def new
    @account = Current.account
    @member_profile = Current.account.build_member_profile
    @prefectures = MPrefecture.all.order(:code)
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
