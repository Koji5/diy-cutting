class AddressesController < ApplicationController
  before_action :set_address, only: [:edit, :update, :destroy]

  def index
    @addresses = Current.account.addresses
  end

  #def new
  #  @address = Current.account.addresses.build
  #end

  def new_modal
    @address = Current.account.addresses.build
    render layout: (turbo_frame_request? ? false : "application")
  end

  def create
    @address = Current.account.addresses.build(address_params)
    if @address.save
      redirect_to addresses_path, notice: "住所を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @address.update(address_params)
      redirect_to addresses_path, notice: "住所を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    redirect_to addresses_path, notice: "住所を削除しました"
  end

  private

  def set_address
    @address = Current.account.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(
      :postal_code, :prefecture_code, :city_code, :address_line,
      :recipient_name, :phone_number, :label, :default_flag
    )
  end
end
