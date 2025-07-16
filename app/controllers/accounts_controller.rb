class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account

  def show
  end

  def edit
    @account.user ||= User.find_by(id: @account.user_id)
  end

  def update
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

    begin
      ActiveRecord::Base.transaction do
        @account.update!(account_params)
        @account.user.update!(user_params) if user_params.present?
      end
      render_flash_and_replace_main(
        template: "accounts/show",
        assigns: { account: @account },
        message: "アカウント基本情報を更新しました。",
        type: "success"
      )
    rescue ActiveRecord::RecordInvalid
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
      :nickname, :legal_type, :name, :name_kana, :birthday, :gender#,
      #user_attributes: [:id, :email, :password, :password_confirmation]
    )
  end

  def user_params
    return {} unless params[:account][:user]

    permitted = params.require(:account).require(:user).permit(:id, :email, :password, :password_confirmation)

    # パスワード未入力なら password 関連を除外（メールだけ更新する）
    if permitted[:password].blank?
      permitted.except(:password, :password_confirmation)
    end

    permitted
  end
end
