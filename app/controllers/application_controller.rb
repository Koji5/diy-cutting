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

  # Turbo Streamでmainフレームを更新し、同時にアラート領域(alert-container)を再描画する
  #
  # @param template [String] レンダリングするテンプレートのパス（例: "articles/show"）
  # @param assigns [Hash] テンプレートに渡すインスタンス変数（localsではなくassigns）
  # @param message [String, nil] flashに表示するメッセージ（例: "保存しました"）
  # @param type [Symbol, nil] flashのタイプ（:notice, :alert, :error, :warningなど）
  # @param flash [Hash, nil] 外部から渡したflash（通常は省略。自動でself.flashを使用）
  #
  # 使用例:
  #   render_flash_and_replace_main(
  #     template: "articles/show",
  #     assigns: { article: @article },
  #     message: "記事を更新しました",
  #     type: :notice
  #   )
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

  # Turbo Streamで任意のフレーム(target_id)を更新し、同時にアラート領域(alert-container)も再描画する
  #
  # @param target_id [String] Turbo Frame ID。更新対象のDOM要素（例: "main"）
  # @param template [String, nil] レンダリングするテンプレートのパス
  # @param assigns [Hash] テンプレートに渡すインスタンス変数（assigns形式）
  # @param partial [String, nil] パーシャルレンダリングを行う場合のパス（優先される）
  # @param locals [Hash] パーシャルに渡すローカル変数
  # @param message [String, nil] flashに表示するメッセージ（任意）
  # @param type [Symbol, nil] flashのタイプ（例: :notice, :alert など）
  # @param flash [Hash, nil] 外部から渡すflash（通常は省略でself.flash）
  #
  # 使用例:
  #   render_flash_and_replace(
  #     target_id: "sidebar",
  #     partial: "shared/aside",
  #     locals: { filters: @filters },
  #     message: "フィルタを更新しました",
  #     type: :info
  #   )
  def render_flash_and_replace(target_id: nil, template: nil, assigns: {}, message: nil, type: nil, partial: nil, locals: {}, flash: nil)
    hide_script = <<~SCRIPT
      <script>
        (() => {
          const loader = window.Stimulus?.getControllerForElementAndIdentifier(document.body, "page-loading");
          loader?.hide();
        })();
      </script>
    SCRIPT

    flash ||= self.flash

    if message.present? && type.present?
      flash[type] = Array(flash[type]) << message
    end

    render turbo_stream: [
      turbo_stream.update(
        "alert-container",
        ApplicationController.render(
          partial: "shared/alert",
          locals: { flash: flash }
        )
      ),
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
