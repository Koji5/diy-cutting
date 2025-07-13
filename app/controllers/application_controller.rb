class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_current_account
  layout -> { turbo_frame_request? ? "main_frame" : "application" }

  private

  def set_current_account
    if defined?(current_user) && current_user&.account
      Current.account = current_user.account
    end
  end
end
