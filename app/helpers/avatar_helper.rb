module AvatarHelper
  def user_avatar(user, options = {})
    size = options[:size] || 40
    classes = "rounded-full bg-dark-900 flex items-center justify-center text-blue-500 #{options[:class]} "
    style = "width: #{size}px; height: #{size}px;"
    
    content_tag :div, class: classes, style: style do
      content_tag :span, user.username[0].upcase, class: "text-lg font-bold"
    end
  end
end
