require 'classy_enum/macros'

enum :<%= class_name.underscore %>
<% values.each do |arg| %>
  enum :<%= arg.underscore %>
<%- end -%>
end

# alternative (use --simple)
# enum_for :color, [:red, :blue]
