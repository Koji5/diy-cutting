class PartsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_member_or_affiliate

  def new
    @part = Part.new
    load_masters
  end

  def create
    @part = current_user.parts.build(part_params)

    if @part.save
      redirect_to new_part_path, notice: "部品を登録しました"
    else
      load_masters
      render :new, status: :unprocessable_entity
    end
  end

  private

  # ロールチェック（member or affiliate）
  def require_member_or_affiliate
    return if user_signed_in? && (current_user.member? || current_user.affiliate?)

    render file: Rails.root.join("public/403.html"),
           status: :forbidden, layout: false
  end

  def part_params
    params.require(:part).permit(
      :name, :material_category_code, :material_code, :shape_code,
      :paint_type_code, :thickness_mm, :width1_mm, :width2_mm, :length_mm,
      :shape_json, :corner_proc_json, :hole_json, :sqhole_json,
      :edge_json, :paint_json, :note
    )
  end

  def load_masters
    @material_categories = MCategory.order(:code)
    @materials           = MMaterial.order(:code)
    @shapes              = MShape.order(:code)
    @paint_types         = MPaintType.order(:code)
  end
end
