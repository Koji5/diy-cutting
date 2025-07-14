module ApplicationHelper
  def turbo_frame_wrap(condition = true, id:, &block)
    if condition != false
      content_tag(:turbo_frame, capture(&block), id: id)
    else
      capture(&block)
    end
  end
end
