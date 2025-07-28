# app/controllers/recipes_controller.rb
class RecipesController < ApplicationController
  before_action :authenticate_user!

  def index
    # 今は全件。次フェーズで検索・並び替えを入れる
    @recipes = Current.account.recipes
                          .includes(:origin_owner, thumbnail_attachment: :blob)
                          .order(updated_at: :desc)
    render_flash_and_replace_main(
        template: "recipes/index",
        assigns: { recipes: @recipes }
    )
  end

  def show
    @recipe = Current.account.recipes.find(params[:id])
    # レシピに含まれているパーツ
    @recipe_parts = @recipe.recipe_parts.includes(part: { thumbnail_attachment: :blob })
    @carts = Current.account.carts.includes(cart_recipes: :recipe)
    render_flash_and_replace_main(
        template: "recipes/show",
        assigns: {
          recipe: @recipe,
          recipe_parts: @recipe_parts,
          carts: @carts
        }
    )
  end

  def show_modal
    @recipe = Current.account.recipes.find(params[:id])
    # レシピに含まれているパーツ
    @recipe_parts = @recipe.recipe_parts.includes(part: { thumbnail_attachment: :blob })
    render layout: (turbo_frame_request? ? false : "application")
  end

  def new
    @recipe = Recipe.new
    @parts = Current.account.parts
                     .kept
                     .includes(thumbnail_attachment: :blob)
                     .order(:name)
    render_flash_and_replace_main(
        template: "recipes/new",
        assigns: {
          recipe: @recipe,
          parts: @parts
        }
    )
  end

  def create
    @recipe = Current.account.recipes.build(recipe_params)

    # parts_json から recipe_parts を組み立てる
    if (json = params.dig(:recipe, :parts_json)).present?
      JSON.parse(json).each do |h|
        @recipe.recipe_parts.build(part_id: h['part_id'], quantity: h['qty'])
      end
    end

    # レシピに含まれているパーツ
    @recipe_parts = @recipe.recipe_parts.includes(part: { thumbnail_attachment: :blob })
    @carts = Current.account.carts.includes(cart_recipes: :recipe)

    if @recipe.save
      render_flash_and_replace_main(
        template: "recipes/show",
        assigns: {
          recipe: @recipe,
          recipe_parts: @recipe_parts,
          carts: @carts
        },
        message: "レシピを登録しました。",
        type: :notice
      )
    else
      flash[:alert] = @recipe.errors.full_messages
      render_flash_and_replace(
          flash: flash
      )
    end
  end

  def edit
    @recipe = Current.account.recipes.find(params[:id])
    # レシピに含まれているパーツ
    @recipe_parts = @recipe.recipe_parts.includes(part: { thumbnail_attachment: :blob })
    # レシピに含まれていないパーツ
    @excluded_parts = Current.account.parts
                              .includes(thumbnail_attachment: :blob)
                              .where.not(id: @recipe.recipe_parts.select(:part_id))
    render_flash_and_replace_main(
      template: "recipes/edit",
      assigns: {
        recipe: @recipe,
        recipe_parts: @recipe_parts,
        excluded_parts: @excluded_parts
      }
    )
  end

  def update
    @recipe = Current.account.recipes.find(params[:id])

    begin
      ActiveRecord::Base.transaction do
        @recipe.update!(recipe_params) # ← 成功しなければ即例外
        if params[:recipe][:remove_thumbnail] == "1"
          @recipe.thumbnail.purge
        end
        parts_data = JSON.parse(params[:recipe][:parts_json], symbolize_names: true)
        sync_recipe_parts(parts_data)  # ← 失敗したらここで例外
      end
      render_flash_and_replace_main(
        template: "recipes/show",
        assigns: {
          recipe: @recipe,
          recipe_parts: @recipe.recipe_parts.includes(part: { thumbnail_attachment: :blob }),
          carts: Current.account.carts.includes(cart_recipes: :recipe)
        },
        message: "レシピを更新しました",
        type: :notice
      )
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = e.record.errors.full_messages
      render_flash_and_replace(
          flash: flash
      )
    rescue => e
      render_flash_and_replace(
        message: "レシピを更新できませんでした: #{e.message}",
        type: :alert
      )
    end
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy
    flash[:notice] = Array(flash[:notice]) << "レシピ「#{@recipe.name}」を削除しました。"
    render_flash_and_remove(dom_id: @recipe, flash: flash)
  end

  private

  def recipe_params
    params.require(:recipe).permit(:name, :thumbnail).merge(status: :draft)
  end

  def sync_recipe_parts(parts_data)
    if parts_data.blank?
      # すべて削除（レシピに紐づくパーツが空になった）
      @recipe.recipe_parts.destroy_all
      return
    end

    # 現在の中間データ（part_id をキーに）
    current_parts = @recipe.recipe_parts.index_by(&:part_id)
    new_part_ids  = parts_data.map { |p| p[:part_id] }

    # 1. 更新 or 追加
    parts_data.each do |entry|
      part_id  = entry[:part_id]
      quantity = entry[:qty].to_i

      if current_parts[part_id]
        current_parts[part_id].update!(quantity: quantity)
      else
        @recipe.recipe_parts.create!(part_id: part_id, quantity: quantity)
      end
    end

    # 2. 削除（存在していたが送られてこなかったパーツ）
    to_remove = current_parts.keys - new_part_ids
    @recipe.recipe_parts.where(part_id: to_remove).destroy_all
  end

end
