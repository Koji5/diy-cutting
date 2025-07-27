class CartsController < ApplicationController

  def index
    # 今は全件。次フェーズで検索・並び替えを入れる
    @carts = Current.account.carts.order(updated_at: :desc)
    render_flash_and_replace_main(
        template: "carts/index",
        assigns: { carts: @carts }
    )
  end

  def new
    prepare_cart_form_data
    render_flash_and_replace_main(
        template: "carts/new",
        assigns: {
          cart: @cart,
          excluded_recipes: @excluded_recipes,
          parts: @parts,
          recipes: @recipes
        }
    )
  end

  def create
    @cart = Current.account.carts.build(cart_params)
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
      # カートに含まれているパーツ
      @cart_parts = @cart.cart_parts.includes(part: { thumbnail_attachment: :blob })
      # カートに含まれているレシピ
      @cart_recipes = @cart.cart_recipes.includes(recipe: { thumbnail_attachment: :blob })

      render_flash_and_replace_main(
        template: "carts/show",
        assigns: {
          cart: @cart,
          cart_parts: @cart_parts,
          cart_recipes: @cart_recipes
        },
        message: "カートを登録しました。",
        type: :notice
      )
    else
      flash[:alert] = @cart.errors.full_messages
      render_flash_and_replace(
          flash: flash
      )
    end
  end

  def edit
    @cart = Current.account.carts.find(params[:id])
    # カートに含まれているパーツ
    @cart_parts = @cart.cart_parts.includes(part: { thumbnail_attachment: :blob })
    # カートに含まれていないパーツ
    @excluded_parts = Current.account.parts
                                  .includes(thumbnail_attachment: :blob)
                                  .where.not(id: @cart.cart_parts.select(:part_id))
    # カートに含まれているレシピ
    @cart_recipes = @cart.cart_recipes.includes(recipe: { thumbnail_attachment: :blob })
    # カートに含まれていないレシピ
    @excluded_recipes = Current.account.recipes
                                    .includes(thumbnail_attachment: :blob)
                                    .where.not(id: @cart.cart_recipes.select(:recipe_id))
    render_flash_and_replace_main(
        template: "carts/edit",
        assigns: {
          cart: @cart,
          cart_parts: @cart_parts,
          cart_recipes: @cart_recipes,
          excluded_parts: @excluded_parts,
          excluded_recipes: @excluded_recipes
        }
    )
  end

  def update
    @cart = Current.account.carts.find(params[:id])

    begin
      ActiveRecord::Base.transaction do
        @cart.update!(cart_params) # ← 成功しなければ即例外
        parts_data    = JSON.parse(params[:cart][:parts_json], symbolize_names: true)
        recipes_data  = JSON.parse(params[:cart][:recipes_json], symbolize_names: true)
        sync_cart_parts(parts_data)  # ← 失敗したらここで例外
        sync_cart_recipes(recipes_data)  # ← 失敗したらここで例外
      end
      render_flash_and_replace_main(
          template: "carts/show",
          assigns: {
            cart: @cart,
            cart_parts: @cart_parts,
            cart_recipes: @cart_recipes
          },
          message: "カートを更新しました",
          type: :notice
      )
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = e.record.errors.full_messages
      render_flash_and_replace(
          flash: flash
      )
    rescue JSON::ParserError => e
      render_flash_and_replace(
          message: "カートを更新できませんでした。１件も選択されていない可能性があります。",
          type: :alert
      )
    end
  end

  def show
    @cart = Current.account.carts.find(params[:id])
    # カートに含まれているパーツ
    @cart_parts = @cart.cart_parts.includes(part: { thumbnail_attachment: :blob })
    # カートに含まれているレシピ
    @cart_recipes = @cart.cart_recipes.includes(recipe: { thumbnail_attachment: :blob })
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

  def prepare_cart_form_data
    @cart = Cart.new
    if params[:recipe_id].present?
      @recipe = Recipe.includes(thumbnail_attachment: :blob).find(params[:recipe_id])
      @recipes = Current.account.recipes
                      .where.not(id: @recipe.id)
                      .includes(thumbnail_attachment: :blob)
                      .order(updated_at: :desc)
      @excluded_recipes = [@recipe]
    else
      @recipes = Current.account.recipes
                      .includes(thumbnail_attachment: :blob)
                      .order(updated_at: :desc)
      @excluded_recipes = []
    end
    @parts = Current.account.parts
                     .kept
                     .includes(thumbnail_attachment: :blob)
                     .order(:name)
  end

  def cart_params
    params.require(:cart).permit(:name).merge(status: :draft)
  end

  def sync_cart_parts(parts_data)
    if parts_data.blank?
      # すべて削除（レシピに紐づくパーツが空になった）
      @cart.cart_parts.destroy_all
      return
    end

    # 現在の中間データ（part_id をキーに）
    current_parts = @cart.cart_parts.index_by(&:part_id)
    new_part_ids  = parts_data.map { |p| p[:part_id] }

    # 1. 更新 or 追加
    parts_data.each do |entry|
      part_id  = entry[:part_id]
      quantity = entry[:qty].to_i

      if current_parts[part_id]
        current_parts[part_id].update!(quantity: quantity)
      else
        @cart.cart_parts.create!(part_id: part_id, quantity: quantity)
      end
    end

    # 2. 削除（存在していたが送られてこなかったパーツ）
    to_remove = current_parts.keys - new_part_ids
    @cart.cart_parts.where(part_id: to_remove).destroy_all
  end

  def sync_cart_recipes(recipes_data)
    if recipes_data.blank?
      # すべて削除（レシピに紐づくパーツが空になった）
      @cart.cart_recipes.destroy_all
      return
    end

    # 現在の中間データ（part_id をキーに）
    current_recipes = @cart.cart_recipes.index_by(&:recipe_id)
    new_recipe_ids  = recipes_data.map { |p| p[:recipe_id] }

    # 1. 更新 or 追加
    recipes_data.each do |entry|
      recipe_id  = entry[:recipe_id]
      quantity = entry[:qty].to_i

      if current_recipes[recipe_id]
        current_recipes[recipe_id].update!(quantity: quantity)
      else
        @cart.cart_recipes.create!(recipe_id: recipe_id, quantity: quantity)
      end
    end

    # 2. 削除（存在していたが送られてこなかったパーツ）
    to_remove = current_recipes.keys - new_recipe_ids
    @cart.cart_recipes.where(recipe_id: to_remove).destroy_all
  end

#  def load_cart_edit_data
#    # 1. parts_json から再構築
#    parts_data = JSON.parse(params[:cart][:parts_json], symbolize_names: true)

#    # 2. 関連する Part をまとめて preload
#    part_ids = parts_data.map { |entry| entry[:part_id] }
#    preloaded_parts = Part.where(id: part_ids).includes(thumbnail_attachment: :blob).index_by(&:id)

 #   # 3. cart_parts を仮想的に復元（保存されていない状態）
 #   @cart.cart_parts = parts_data.map do |entry|
 #     part = preloaded_parts[entry[:part_id]]
 #     @cart.cart_parts.build(part: part, quantity: entry[:qty])
 #   end

 #   # 4. 含まれていないパーツを抽出
 #   used_part_ids = parts_data.map { |p| p[:part_id] }
 #   @excluded_parts = Current.account.parts
 #                             .includes(thumbnail_attachment: :blob)
 #                             .where.not(id: used_part_ids)

  #  # 1. recipes_json から再構築
  #  recipes_data = JSON.parse(params[:cart][:recipes_json], symbolize_names: true)

#    # 2. 関連する Part をまとめて preload
#    recipe_ids = recipes_data.map { |entry| entry[:recipe_id] }
#    preloaded_recipes = Recipe.where(id: recipe_ids).includes(thumbnail_attachment: :blob).index_by(&:id)

#    # 3. cart_recipes を仮想的に復元（保存されていない状態）
#    @cart.cart_recipes = recipes_data.map do |entry|
#      recipe = preloaded_recipes[entry[:recipe_id]]
#      @cart.cart_recipes.build(recipe: recipe, quantity: entry[:qty])
#    end

#    # 4. 含まれていないパーツを抽出
#    used_recipe_ids = recipes_data.map { |p| p[:recipe_id] }
#    @excluded_recipes = Current.account.recipes
#                              .includes(thumbnail_attachment: :blob)
#                              .where.not(id: used_recipe_ids)
#  end
end