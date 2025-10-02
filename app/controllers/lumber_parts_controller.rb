class LumberPartsController < ApplicationController

  before_action :set_part, only: [:edit, :update]

  def new
    @part = Part.new
    @part.build_lumber_part
    render_flash_and_replace_main(
        template: "lumber_parts/new",
        assigns: lumber_masters_assigns.merge(part: @part)
    )
  end

  def create
    @part = Current.account.parts.new(part_params_for_lumber)
    @part.shape_type_code = "lumber" if @part.respond_to?(:shape_type_code) && @part.shape_type_code.blank?

    begin
      ActiveRecord::Base.transaction do
        @part.save!
      end
      render_flash_and_replace_main(
          template: "lumber_parts/edit", #TODO lumber_parts/showにする
          assigns: lumber_masters_assigns.merge(part: @part),
          message: "保存しました",
          type: :notice
      )
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = e.record.errors.full_messages
      render_flash_and_replace(
          flash: flash
      )
    end
  end

  def edit
    raise ActiveRecord::RecordNotFound unless @part.lumber?
    @part.build_lumber_part unless @part.lumber_part  # 念のため
    render_flash_and_replace_main(
        template: "lumber_parts/edit",
        assigns: lumber_masters_assigns.merge(part: @part)
    )
  end

  def update
    replacing_thumb = part_params_for_lumber[:thumbnail].present?
    # 旧 blob を退避（新規ファイルが来るときのみ）
    old_blob = (replacing_thumb && @part.thumbnail.attached?) ? @part.thumbnail.blob : nil

    ActiveRecord::Base.transaction do
      # 形状種別カラムを運用しているなら保険でセット（空のときのみ）
      @part.shape_type_code = "lumber" if @part.respond_to?(:shape_type_code) && @part.shape_type_code.blank?
      @part.update!(part_params_for_lumber)
    end
    if replacing_thumb && old_blob && old_blob != @part.thumbnail.blob
      old_blob.purge_later   # すぐ消すなら purge、通常は purge_later 推奨
    end
    flash[:success] = "更新しました"
    render_flash_and_replace(flash: flash)
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = e.record.errors.full_messages
    render_flash_and_replace(flash: flash)
  end

  private

  def part_params_for_lumber
    p = params.require(:part).permit(
      :name, :note, :thumbnail, # ← Part側
      lumber_part_attributes: [
        :id, :material_code,
        :paint_type_code, :paint_color_code, :paint_finish_code, :paint_gloss_code,
        :lumber_size_code, :length_mm,
        :camera_state_json, # ← ここは {} ではなくスカラ
        { side_json: {}, hole_json: {} }
      ]
    )

    if (attrs = p[:lumber_part_attributes])
      attrs[:camera_state_json] = nil if attrs.key?(:camera_state_json) && attrs[:camera_state_json].blank?
      normalize_lumber_json!(attrs)
    end
    p
  end

  # 保存前正規化（必要なJSONだけでOK）
  # JSON の各数値を to_f、空欄は nil、チェックボックスは true/false にしてから保存
  def normalize_lumber_json!(attrs)
    %i[side_json hole_json].each do |k|
      next unless attrs[k].present?

      # ★ Params→Hash 化（permit 済みなら to_h でOK。未permitの可能性があるなら to_unsafe_h）
      h = attrs[k].is_a?(ActionController::Parameters) ? attrs[k].to_h : attrs[k]

      attrs[k] = h.deep_transform_values do |v|
        case v
        when "", nil
          nil
        when "0", "1"
          v == "1"
        when String
          s = v.strip.downcase
          # "on"/"off" や "true"/"false" などを布教化
          if %w[on true t yes y 1].include?(s)
            true
          elsif %w[off false f no n 0].include?(s)
            false
          else
            Float(v) rescue v
          end
        else
          v
        end
      end
    end
  end

  def set_part
    @part = Current.account.parts
                   .includes(:lumber_part)
                   .find(params[:part_id] || params[:id])  # ← どちらでも拾えるよう保険
  end

  def lumber_masters_assigns
    {
      materials:        MMaterial.order(:sort_order),
      paint_types:      MPaintType.order(:sort_order),
      paint_colors:     MPaintColor.order(:sort_order),
      paint_glosses:    MPaintGloss.order(:sort_order),
      paint_finishes:   MPaintFinish.order(:sort_order),
      edge_processes:   MEdgeProcess.where("allow_types @> ?", { lumber: true }.to_json).order(:sort_order),
      hole_surfaces:    MHoleSurface.order(:sort_order),
      hole_specs:       MHoleSpec.order(:sort_order),
      lumber_sizes:     MLumberSize.order(:sort_order)
    }
  end
end