class LumberPartsController < ApplicationController

  def new
    @part = Part.new
    @part.build_lumber_part
    render_flash_and_replace_main(
        template: "lumber_parts/new",
        assigns: lumber_masters_assigns.merge(part: @part)
    )
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

  def lumber_masters_assigns
    {
      materials:        MMaterial.order(:sort_order),
      paint_types:      MPaintType.order(:sort_order),
      paint_colors:     MPaintColor.order(:sort_order),
      paint_glosses:    MPaintGloss.order(:sort_order),
      paint_finishes:   MPaintFinish.order(:sort_order),
      edge_processes:   MEdgeProcess.order(Arel.sql("CASE WHEN code = 'NONE' THEN 0 ELSE 1 END"), :code),
      hole_surfaces:    MHoleSurface.order(:sort_order),
      hole_specs:       MHoleSpec.order(:sort_order),
      #lumber_edges:     MLumberEdge.order(:sort_order),   # TODO
      lumber_sizes:     MLumberSize.order(:sort_order)
    }
  end
end