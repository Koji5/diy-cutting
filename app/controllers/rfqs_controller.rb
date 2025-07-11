class RfqsController < ApplicationController

  def new
    @cart = Cart.find(params[:cart_id])
    @parts = RfqBuilder.new(@cart, view_context).build_parts  # レシピとパーツを展開・合算
    @rfq = Rfq.new
  end

end