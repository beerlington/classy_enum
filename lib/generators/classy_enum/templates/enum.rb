class <%= class_name %> < ClassyEnum::Base
  enum_classes <%= values.map {|a| ":#{a}"}.join(", ") %>
end
<% values.each do |arg| %>
class <%= class_name + arg.camelize %>
end
<% end %>
