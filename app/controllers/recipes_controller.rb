# app/controllers/recipes_controller.rb
class RecipesController < ApplicationController

  def index
    # 今は全件。次フェーズで検索・並び替えを入れる
    @recipes = current_user.recipes.kept.with_attached_thumbnail.includes(:origin_owner).order(updated_at: :desc)
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
