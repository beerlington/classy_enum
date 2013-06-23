require 'test_helper'
<% values.each do |arg| %>
class <%= "#{class_name}::#{arg.camelize}Test" %> < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
<%- end -%>
