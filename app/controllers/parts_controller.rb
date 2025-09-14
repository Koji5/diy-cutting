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

  private

end
