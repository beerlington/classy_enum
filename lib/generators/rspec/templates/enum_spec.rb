require 'spec_helper'
<% values.each do |arg| %>
describe <%= "#{class_name}::#{arg.camelize}" %> do
  pending "add some examples to (or delete) #{__FILE__}"
end
<%- end -%>
