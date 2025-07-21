class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account

  def show
    @account = Current.account
    @member_profile = @account.member_profile
    @addresses = @account.addresses.includes(:prefecture, :city)

    # フラッシュメッセージの条件分岐
    if @account.has_role?(:member) && @member_profile.nil?
      message = "お客様プロフィールが未登録です。作成してください。"
      type = "warning"
    else
      message = nil
      type = nil
    end

    render_flash_and_replace_main(
      template: "accounts/show",
      assigns: {
        account: @account,
        member_profile: @member_profile,
        addresses: @addresses
      },
      message: message,
      type: type
    )
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

  def toggle_role
    account = Current.account
    role = params[:role].to_sym
    enabled = ActiveModel::Type::Boolean.new.cast(params[:enabled])

    if enabled
      account.add_role(role)
    else
      account.remove_role(role)
    end

    if account.save
      role_label = {
        member: "お客様機能",
        vendor: "業者様機能",
        admin: "管理機能",
        affiliate: "アフィリエイト機能"
      }[role]

      action_label = enabled ? "有効にしました" : "無効にしました"
      message = "#{role_label}を#{action_label}。"
      flash_stream = turbo_stream.update(
        "flash-messages",
        ApplicationController.render(
          partial: "shared/flash",
          formats: [:html],
          locals: {
            type: "success",
            message: message
          }
        )
      )
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(
              "#{role}-actions",
              partial: "accounts/#{role}_actions",
              formats: [:html],
              locals: { account: account }
            ),
            turbo_stream.update(
              "sidebar",
              partial: "shared/app_links",
              formats: [:html],
              locals: { placement: :side }
            ),
            flash_stream
          ]
        end
      end
    else
      # ゲスト化（role_flags = 0）は禁止
      render turbo_stream: turbo_stream.update(
        "flash-messages",
        ApplicationController.render(
          partial: "shared/flash",
          locals: {
            type: "danger",
            message: account.errors.full_messages.to_sentence.presence || "更新に失敗しました"
          }
        )
      ), status: :unprocessable_entity
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
