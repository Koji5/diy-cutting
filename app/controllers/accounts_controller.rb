class AccountsController < ApplicationController
  include AccountDashboardRenderable
  before_action :authenticate_user!
  before_action :set_account

  def show
    render_account_dashboard
  end

  def edit
    @account.user ||= User.find_by(id: @account.user_id)
    render_flash_and_replace_main(
      template: "accounts/edit",
      assigns: { account: @account }
    )
  end

  def update
    if user_params[:password].present?
      # パスワード変更を希望している
      unless @account.user.valid_password?(params[:current_password])
        render_flash_and_replace(
          #template: "accounts/edit",
          #assigns: { account: @account },
          message: "現在のパスワードが正しくありません。",
          type: :alert
        )
        return
      end
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
        type: :notice
      )
    rescue ActiveRecord::RecordInvalid => e
      # password_confirmation はモデル側のバリデーションに任せてOK
      flash[:alert] = e.record.errors.full_messages
      render_flash_and_replace(
        flash: flash
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
      type = :notice
      flash[type] = Array(flash[type]) << message
      flash_stream = turbo_stream.update(
        "alert-container",
        ApplicationController.render(
          partial: "shared/alert",
          locals: { flash: flash }
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
      flash[:alert] = account.errors.full_messages
      render turbo_stream: turbo_stream.update(
        "alert-container",
        ApplicationController.render(
          partial: "shared/alert",
          locals: { flash: flash }
        )
      ), status: :unprocessable_entity
    end
    flash.discard if flash.present?
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
