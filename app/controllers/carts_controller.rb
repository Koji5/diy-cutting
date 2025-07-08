class CartsController < ApplicationController

  def index
    # 今は全件。次フェーズで検索・並び替えを入れる
    @carts = current_user.carts.order(updated_at: :desc)
  end

  def new
    @cart = Cart.new
    if params[:recipe_id].present?
      @recipe = Recipe.includes(thumbnail_attachment: :blob).find(params[:recipe_id])
      @recipes = current_user.recipes
                      .where.not(id: @recipe.id)
                      .with_attached_thumbnail
                      .order(updated_at: :desc)
      @excluded_recipes = [@recipe]
    else
      @recipes = current_user.recipes
                      .with_attached_thumbnail
                      .order(updated_at: :desc)
      @excluded_recipes = []
    end
    @parts = current_user.parts
                     .kept
                     .with_attached_thumbnail
                     .order(:name)
  end

  def create
    @cart = current_user.carts.build(cart_params)
    if (json = params.dig(:cart, :parts_json)).present?
      JSON.parse(json).each do |h|
        @cart.cart_parts.build(part_id: h['part_id'], quantity: h['qty'])
      end
    end
    if (json = params.dig(:cart, :recipes_json)).present?
      JSON.parse(json).each do |h|
        @cart.cart_recipes.build(recipe_id: h['recipe_id'], quantity: h['qty'])
      end
    end

    if @cart.save
      flash[:notice] = '保存しました'
      redirect_to new_cart_path
    else
      @carts = Cart.order(:name)
      render :new, status: :unprocessable_entity
    end
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

  private

  def cart_params
    params.require(:cart).permit(:name).merge(status: :draft)
  end

end