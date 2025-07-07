class CartsController < ApplicationController

  def index
    # 今は全件。次フェーズで検索・並び替えを入れる
    @carts = current_user.carts.order(updated_at: :desc)
  end

  def new
    @cart = Cart.new
    @recipe = Recipe.find(params[:recipe_id]) if params[:recipe_id].present?
    @parts = current_user.parts
                     .kept
                     .with_attached_thumbnail
                     .order(:name)
  end

  def destroy
    @cart = Cart.find(params[:id])
    @cart.destroy

    respond_to do |format|
      # Turbo Drive (通常のリンク) → 行を DOM から外す
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(helpers.dom_id(@cart))
      end

      # 非 Turbo (従来のブラウザ遷移) → 一覧へリダイレクト
      format.html do
        redirect_to carts_path,
                    status: :see_other,
                    notice: "カート「#{@cart.name}」を削除しました。"
      end
    end
  end
end