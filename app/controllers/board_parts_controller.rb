class BoardPartsController < ApplicationController

  before_action :set_part, only: [:edit]

  def new
    @part = Part.new
    @part.build_board_part
    render_flash_and_replace_main(
        template: "board_parts/new",
        assigns: {
          part: @part,
          materials:           MMaterial.order(:sort_order),
          paint_types:         MPaintType.order(:sort_order),
          paint_colors:        MPaintColor.order(:sort_order),
          paint_glosses:       MPaintGloss.order(:sort_order),
          edge_processes:      MEdgeProcess.order(Arel.sql("CASE WHEN code = 'NONE' THEN 0 ELSE 1 END"), :code),
          corner_processes:    MCornerProcess.order(Arel.sql("CASE WHEN code = 'NONE' THEN 0 ELSE 1 END"), :code),
          side_processes:      MSideProcess.order(Arel.sql("CASE WHEN code = 'NONE' THEN 0 ELSE 1 END"), :code),
          hole_surfaces:       MHoleSurface.order(:sort_order),
          hole_specs:          MHoleSpec.order(:sort_order),
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
    p = params.require(:part).permit(
      :name, :material_code, # ← Part側
      board_part_attributes: [
        :material_code,
        :paint_type_code, :paint_color_code, :paint_finish_code, :paint_gloss_code,
        :thickness_mm, :width_mm, :length_mm,
        :camera_state_json, # ← ここは {} ではなくスカラ
        { corner_json: {}, side_json: {}, edge_json: {}, hole_json: {}, sqhole_json: {} }
      ]
    )

    if (attrs = p[:board_part_attributes])
      normalize_board_json!(attrs)
    end
    p
  end

  # 保存前正規化（必要なJSONだけでOK）
  # JSON の各数値を to_f、空欄は nil、チェックボックスは true/false にしてから保存
  def normalize_board_json!(attrs)
    %i[corner_json side_json].each do |k|
      next unless attrs[k].is_a?(Hash)
      attrs[k] = attrs[k].deep_transform_values do |v|
        case v
        when Hash
          v
        when "", nil
          nil
        when "0", "1"
          v == "1"
        else
          Float(v) rescue v
        end
      end
    end
  end

  def set_part
    @part = Current.account.parts.find(params[:part_id])
  end

end