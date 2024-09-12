module ApplicationHelper
    def render_flash_messages
        flash.map do |type, message|
            tag.div message, 
              class: [
                {
                   notice: 'is-success',
                   alert: 'is-danger',
                   error: 'is-danger'
                }.fetch(type.to_sym, type.to_s), 
                "notification", 
                "is-light", 
                "text-center"
              ]
        end.join.html_safe
    end
end
