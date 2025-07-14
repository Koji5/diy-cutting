class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account

  def show
  end

  def edit
  end

  def update
    user_params = account_params[:user_attributes]
    if user_params[:password].present?
      # パスワード変更を希望している
      unless @account.user.valid_password?(params[:current_password])
        render_flash_and_replace_main(
          template: "accounts/edit",
          assigns: { account: @account },
          message: "現在のパスワードが正しくありません。",
          type: "danger"
        )
        return
      end
      # password_confirmation はモデル側のバリデーションに任せてOK
    end

    if @account.update(account_params)
      render_flash_and_replace_main(
        template: "accounts/show",
        assigns: { account: @account },
        message: "アカウント基本情報を更新しました。",
        type: "success"
      )
    else
      render_flash_and_replace_main(
        template: "accounts/edit",
        assigns: { account: @account },
        message: "エラーが発生しました。",
        type: "danger"
      )
    end
  end

  private

  def set_account
    @account = Current.account  # ← 他人のアカウントを見せたくないならこれで固定
  end

  def account_params
    params.require(:account).permit(
      :nickname, :legal_type, :name, :name_kana, :birthday, :gender,
      user_attributes: [:id, :email, :password, :password_confirmation]
    )
  end
end