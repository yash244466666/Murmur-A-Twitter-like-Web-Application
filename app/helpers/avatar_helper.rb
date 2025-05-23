module AvatarHelper
    def user_avatar(user, options = {})
        size = options[:size] || 40
        outer_classes = "rounded-full #{options[:class]}"
        inner_classes = "rounded-full bg-slate-700 flex items-center justify-center"
        style = "width: #{size}px; height: #{size}px;"
        
        content_tag :div, class: outer_classes do
          content_tag :div, class: inner_classes, style: style do
            content_tag :span, user.username[0..1].upcase, class: "text-white font-bold text-lg"
          end
        end
    end
end
