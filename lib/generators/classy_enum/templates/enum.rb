class <%= class_name %> < ClassyEnum::Base
end
<% values.each do |arg| %>
class <%= "#{class_name}::#{arg.camelize}" %> < <%= class_name %>
end
<%- end -%>
