class LumberPartsController < ApplicationController

  def new
    #@part = Part.new
    #@part.build_lumber_part
  end

  def create
    #@part = Part.new(part_params_for_lumber)
    #if @part.save
    #  redirect_to @part, notice: "角材パーツを作成しました"
    #else
    #  render :new, status: :unprocessable_entity
    #end
  end

  private

  def part_params_for_lumber
    params.require(:part).permit(
      :name, :material_code, :shape_type_code,
      lumber_part_attributes: [
        :side_a_mm, :side_b_mm, :length_mm, :note # 例：角材専用カラム
      ]
    )
  end
end