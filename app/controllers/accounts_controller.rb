class AccountsController < ApplicationController
  before_action :set_account

  def show
  end

  def edit
  end

  def update
    if @account.update(account_params)
      redirect_to @account, notice: "プロフィールを更新しました。"
    else
      render :edit
    end
  end

  private

  def set_account
    @account = Current.account  # ← 他人のアカウントを見せたくないならこれで固定
  end

end