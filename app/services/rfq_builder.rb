# app/services/rfq_builder.rb
class RfqBuilder
  include Rails.application.routes.url_helpers  # url_forのために必要
  include ActionView::Helpers::AssetUrlHelper   # 必要なら

  def initialize(cart, view_context)
    @cart = cart
    @view = view_context  # url_forを安全に呼ぶためにview contextを注入
  end

  def build_parts
    raw_parts = expand_cart_parts_and_recipes  # ここで合算など
    raw_parts.map do |part, quantity|
      {
        id: part.id,
        name: part.name,
        quantity: quantity,
        thumbnail_url: part.thumbnail.attached? ? @view.url_for(part.thumbnail.variant(resize_to_limit: [100, 100])) : nil
      }
    end
  end

  private

  def expand_cart_parts_and_recipes
    result = Hash.new(0)

    # ① カートに直接入っているパーツ
    @cart.cart_parts.includes(:part).each do |cart_part|
      result[cart_part.part] += cart_part.quantity
    end

    # ② レシピに含まれるパーツ（* カートに入っているレシピの分）
    @cart.cart_recipes.includes(recipe: { recipe_parts: :part }).each do |cart_recipe|
      cart_recipe.recipe.recipe_parts.each do |recipe_part|
        # レシピ1つ分のパーツ * カートにそのレシピが入っている個数
        total_quantity = recipe_part.quantity * cart_recipe.quantity
        result[recipe_part.part] += total_quantity
      end
    end

    result  # => { Part => quantity, ... }
  end
end
