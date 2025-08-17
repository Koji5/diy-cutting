class BoardPartsController < ApplicationController

  before_action :set_part, only: [:edit]

  def new
    @part = Part.new
    @part.build_board_part
    render_flash_and_replace_main(
        template: "board_parts/new",
        assigns: {
          part: @part,
          materials:           MMaterial.order(:code),
          paint_types:         MPaintType.order(:code),
          paint_colors:        MPaintColor.order(:code),
          paint_glosses:       MPaintGloss.order(:code),
          edge_processes:      MEdgeProcess.order(:code),
          corner_processes:    MCornerProcess.order(:code),
          board_thickness:     MBoardThickness.order(:code)
        }
    )
  end

  def create

  end

  def edit
    @part = Current.account.parts.includes(:board_part).find(params[:id])
    raise ActiveRecord::RecordNotFound unless @part.board?
    @part.build_board_part unless @part.board_part  # 念のため
  end

  private

  def part_params_for_board
    params.require(:part).permit(
      :name, :material_code, # ← Part側
      board_part_attributes: [
        :material_code,
        :paint_type_code,
        :paint_color_code,
        :paint_finish_code,
        :paint_gloss_code,
        :thickness_mm,
        :width_mm,
        :length_mm,
        :corner_json,
        :side_json,
        :edge_json,
        :hole_json,
        :sqhole_json,
        :camera_state_json 
      ] # ← BoardPart側
    )
  end

  def set_part
    @part = Current.account.parts.find(params[:part_id])
  end
end