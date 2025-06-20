class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action { Current.user = current_user }  # Devise などのヘルパ
  layout -> { turbo_frame_request? ? "main_frame" : "application" }
end
