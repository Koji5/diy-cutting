module AccountDashboardRenderable
  extend ActiveSupport::Concern

  private

  def render_account_dashboard
    account = Current.account
    member_profile = account.member_profile
    vendor_profile = account.vendor_profile
    addresses = account.addresses.includes(:prefecture, :city)

    if account.has_role?(:member) && member_profile.nil?
      flash[:warning] = Array(flash[:warning]) << "お客様プロフィールが未登録です。作成してください。"
    end
    if account.has_role?(:vendor) && vendor_profile.nil?
      flash[:warning] = Array(flash[:warning]) << "業者様プロフィールが未登録です。作成してください。"
    end
    render_flash_and_replace_main(
      template: "accounts/show",
      assigns: {
        account: account,
        member_profile: member_profile,
        vendor_profile: vendor_profile,
        addresses: addresses
      },
      flash: flash
    )
  end
end
