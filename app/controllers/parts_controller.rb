class PartsController < ApplicationController
  def index
    @parts = Current.account.parts
                     .includes(:board_part, :lumber_part, thumbnail_attachment: :blob) # あれば
                     .order(created_at: :desc)

    case params[:type]
    when "board"
      @parts = @parts.where(shape_type_code: :board).includes(:board_part)
    when "lumber"
      @parts = @parts.where(shape_type_code: :lumber).includes(:lumber_part)
    end

    render_flash_and_replace_main(
      template: "parts/index",
      assigns: { parts: @parts }
    )
  end

  def new
    render_flash_and_replace_main( template: "parts/new" )
  end

  private

end
