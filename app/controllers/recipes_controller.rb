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

  def update
    @recipe = current_user.recipes.find(params[:id])

    begin
      ActiveRecord::Base.transaction do
        @recipe.update!(recipe_params) # ← 成功しなければ即例外
        if params[:recipe][:remove_thumbnail] == "1"
          @recipe.thumbnail.purge
        end
        parts_data = JSON.parse(params[:recipe][:parts_json], symbolize_names: true)
        sync_recipe_parts(parts_data)  # ← 失敗したらここで例外
      end

      redirect_to @recipe, notice: "レシピを更新しました"

    rescue => e
      load_recipe_edit_data
      flash.now[:alert] = "更新に失敗しました: #{e.message}"
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @recipe = current_user.recipes.find(params[:id])
    # レシピに含まれているパーツ
    @recipe_parts = @recipe.recipe_parts.includes(:part)
    @carts = current_user.carts.includes(cart_recipes: :recipe)
  end

  def show_modal
    @recipe = current_user.recipes.find(params[:id])
    # レシピに含まれているパーツ
    @recipe_parts = @recipe.recipe_parts.includes(:part)
    render layout: (turbo_frame_request? ? false : "application")
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

  def load_recipe_edit_data
    # 1. parts_json から再構築
    parts_data = JSON.parse(params[:recipe][:parts_json], symbolize_names: true)

    # 2. recipe_parts を仮想的に復元（保存されていない状態）
    @recipe.recipe_parts = parts_data.map do |entry|
      @recipe.recipe_parts.build(part_id: entry[:part_id], quantity: entry[:qty])
    end

    # 3. 含まれていないパーツを抽出
    used_part_ids = parts_data.map { |p| p[:part_id] }
    @excluded_parts = current_user.parts.where.not(id: used_part_ids)
  end

end
