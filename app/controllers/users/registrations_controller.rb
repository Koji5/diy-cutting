# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  layout "minimal", only: [:new]
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    build_resource({})
    resource.build_account unless resource.account
    respond_with resource
  end

  # POST /resource
  def create
    build_resource(sign_up_params)

    role_name = params[:role]&.to_sym
    allowed_roles = Account::ROLE_BITS.keys.map(&:to_sym)
    resolved_role = allowed_roles.include?(role_name) ? role_name : :member

    # admin を環境変数トークン付きでのみ許可
    if resolved_role == :admin
      token_ok = params[:admin_token].present? &&
                 params[:admin_token] == ENV["ADMIN_SIGNUP_TOKEN"]

      resolved_role = :member unless token_ok
    end

    resource.build_account(
      account_params.merge(
        role_flags: Account::ROLE_BITS[resolved_role]
      )
    )

    resource.save
    yield resource if block_given?

    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  private

  def sign_up_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      account_attributes: [
        :nickname, :legal_type, :name, :name_kana, :birthday, :gender
      ]
    )
  end

  def account_params
    params.require(:user).require(:account_attributes).permit(
      :nickname, :legal_type, :name, :name_kana, :birthday, :gender
    )
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
