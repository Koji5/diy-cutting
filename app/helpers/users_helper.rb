module UsersHelper
  ROLE_BUTTON_CLASSES = {
    "member"    => "btn btn-sm btn-secondary",
    "vendor"    => "btn btn-sm btn-info",
    "admin"     => "btn btn-sm btn-danger",
    "affiliate" => "btn btn-sm btn-warning"
  }.freeze

  # <span class="btn btn-sm btn-secondary">Member</span> のようなボタン風表示を返す
  def role_badge(user)
    label = user.role.titleize
    klass = ROLE_BUTTON_CLASSES[user.role] || "btn btn-sm btn-light"
    content_tag :span, label, class: klass
  end
end