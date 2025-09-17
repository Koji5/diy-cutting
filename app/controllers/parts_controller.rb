class PartsController < ApplicationController
  def index
    @parts = Current.account.parts
                    .with_attached_thumbnail
                    .order(created_at: :desc)

    render_flash_and_replace_main(
      template: "parts/index",
      assigns: { parts: @parts }
    )
  end

  def new
    render_flash_and_replace_main( template: "parts/new" )
  end

  def destroy
    @part = Current.account.parts.find(params[:id])
    name = @part.name
    @part.destroy!

    @parts = Current.account.parts
                    .with_attached_thumbnail
                    .order(created_at: :desc)
    render_flash_and_replace(
      target_id: "part_list",
      partial: "parts/part_list",
      locals: {
        parts: @parts
      },
      message: "#{name} を削除しました",
      type: :notice
    )
  rescue ActiveRecord::RecordNotDestroyed => e
    flash[:alert] = e.record.errors.full_messages
    render_flash_and_replace(flash: flash)
  end

  private

end
