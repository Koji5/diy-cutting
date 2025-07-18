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

  def render_flash_and_replace_main(template:, assigns: {}, message: nil, type: nil)
    hide_script = <<~SCRIPT
      <script>
        (() => {
          const loader = window.Stimulus?.getControllerForElementAndIdentifier(document.body, "page-loading");
          loader?.hide();
        })();
      </script>
    SCRIPT

    render turbo_stream: [
      # message が present? なときのみ flash-messages を更新
      *(message.present? ? [
        turbo_stream.update(
          "flash-messages",
          ApplicationController.render(
            partial: "shared/flash",
            locals: { message: message, type: type }
          )
        )
      ] : []),

      turbo_stream.update("main", render_to_string(template: template, assigns: assigns)),
      turbo_stream.append("main", hide_script)
    ]
  end

  #トーストの場合は以下を使う
  #def render_flash_and_replace_main(template:, assigns: {}, message: "保存しました", type: "success")
  #  render turbo_stream: [
  #    turbo_stream.update("toast-frame", partial: "shared/flash_toast", locals: { message: message, type: type }),
  #    turbo_stream.update("main", render_to_string(template: template, assigns: assigns))
  #  ]
  #end
end
