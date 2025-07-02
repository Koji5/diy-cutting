# app/controllers/recipes_controller.rb
class RecipesController < ApplicationController
  before_action :authenticate_user!
  def index
    # 今は全件。次フェーズで検索・並び替えを入れる
    @recipes = current_user.recipes.with_attached_thumbnail.includes(:origin_owner).order(updated_at: :desc)
  end

  def new
    @recipe = Recipe.new
    @parts = current_user.parts
                     .kept
                     .with_attached_thumbnail
                     .order(:name)
  end

  def create
    @recipe = current_user.recipes.build(recipe_params)

    # parts_json から recipe_parts を組み立てる
    if (json = params.dig(:recipe, :parts_json)).present?
      JSON.parse(json).each do |h|
        @recipe.recipe_parts.build(part_id: h['part_id'], quantity: h['qty'])
      end
    end

    if @recipe.save
      flash[:notice] = '保存しました'
      redirect_to new_recipe_path
    else
      @parts = Part.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @recipe = current_user.recipes.find(params[:id])
    # レシピに含まれているパーツ
    @recipe_parts = @recipe.recipe_parts.includes(:part)
    # レシピに含まれていないパーツ
    @excluded_parts = current_user.parts
                              .where.not(id: @recipe.recipe_parts.select(:part_id))
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy

    respond_to do |format|
      # Turbo Drive (通常のリンク) → 行を DOM から外す
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(helpers.dom_id(@recipe))
      end

      # 非 Turbo (従来のブラウザ遷移) → 一覧へリダイレクト
      format.html do
        redirect_to recipes_path,
                    status: :see_other,
                    notice: "レシピ「#{@recipe.name}」を削除しました。"
      end
    end
  end

  private

  def flash_toast
    render turbo_stream: turbo_stream.update(
      "toast-frame",
      partial: "shared/flash_toast",
      locals: { message: params[:msg], type: params[:type] }
    )
  end

  def render_flash_stream(message: "保存しました", type: "success")
    render turbo_stream: turbo_stream.update(
      "toast-frame",
      partial: "shared/flash_toast",
      locals: { message: message, type: type }
    )
  end

  def recipe_params
    params.require(:recipe).permit(:name, :thumbnail).merge(status: :draft)
  end
end
