class AddressesController < ApplicationController
  before_action :set_address, only: [:edit_modal, :update, :destroy]

  def index
    #@addresses = Current.account.addresses
  end

  def new_modal
    @address = Current.account.addresses.build
    @prefectures = MPrefecture.all.order(:code)
    #モーダルで表示させる場合は、turbo_streamではなくturbo_frameを使用する
    render layout: (turbo_frame_request? ? false : "application")
  end

  def create
    save_address(:create)
  end

  def edit_modal
    @prefectures = MPrefecture.all.order(:code)
    @cities = MCity.where(prefecture_code: @address.prefecture_code).order(:code, :name_ja)
    render layout: (turbo_frame_request? ? false : "application")
  end

  def update
    save_address(:update)
  end

  def destroy
    @address.destroy
    @account = Current.account
    @addresses = @account.addresses.includes(:prefecture, :city)
    render_flash_and_replace(
      target_id: "address_list",
      partial: "addresses/address_list",
      locals: {
        addresses: @addresses
      },
      message: "住所を削除しました。",
      type: :notice
    )
  end

  private

  def set_address
    @address = Current.account.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(
      :postal_code, :prefecture_code, :city_code, :address_line,
      :name, :phone_number, :label, :default_flag, :name_kana, :department
    )
  end

  def save_address(action)
    case action
    when :create
      @address = Current.account.addresses.build(address_params)
      success = @address.save
    when :update
      @address = Current.account.addresses.find(params[:id])
      success = @address.update(address_params)
    else
      raise ArgumentError, "不正なアクション: #{action}"
    end

    verb = case action
          when :create then "登録"
          when :update then "更新"
          else "保存"
          end

    if success
      @account = Current.account
      @addresses = @account.addresses.includes(:prefecture, :city)

      render_flash_and_replace(
        target_id: "address_list",
        partial: "addresses/address_list",
        locals: { addresses: @addresses },
        message: "住所を#{verb}しました。",
        type: :notice
      )
    else
      render_flash_and_replace(
        message: "住所の#{verb}に失敗しました。",
        type: :error
      )
    end
  end
end
