class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_current_account

  private

  def set_current_account
    if defined?(current_user) && current_user&.account
      Current.account = current_user.account
    end
  end

  def render_flash_stream(message: "保存しました", type: "success")
    render turbo_stream: turbo_stream.update(
      "toast-frame",
      partial: "shared/flash_toast",
      locals: { message: message, type: type }
    )
  end

  # mainフレーム限定、messageとtypeは一組限定、flashがあっても双方表示される、messageとflashがなければ、トーストは表示されない
  def render_flash_and_replace_main(template:, assigns: {}, message: nil, type: nil, flash: nil)
    if message.present? && type.present?
      flash ||= self.flash
      flash[type] = Array(flash[type]) << message
    end
    render_flash_and_replace(
      target_id: "main",
      template: template,
      assigns: assigns,
      flash: flash
    )
  end

  def render_flash_and_replace(target_id: nil, template: nil, assigns: {}, message: nil, type: nil, partial: nil, locals: {}, flash: nil)
    hide_script = <<~SCRIPT
      <script>
        (() => {
          const loader = window.Stimulus?.getControllerForElementAndIdentifier(document.body, "page-loading");
          loader?.hide();
        })();
      </script>
    SCRIPT

    if message.present? && type.present?
      flash ||= self.flash
      flash[type] = Array(flash[type]) << message
    end

    render turbo_stream: [
      *(flash.present? ? [
        turbo_stream.update(
          "alert-container",
          ApplicationController.render(
            partial: "shared/alert",
            locals: { flash: flash }
          )
        )
      ] : []),
      *(
        if target_id.present?
          html = if partial.present?
                  render_to_string(partial: partial, locals: locals)
                elsif template.present?
                  render_to_string(template: template, assigns: assigns)
                else
                  ""
                end

          [
            turbo_stream.update(target_id, html),
            turbo_stream.append(target_id, hide_script)
          ]
        else
          []
        end
      )
    ]
    flash.discard if flash.present?
  end
end
