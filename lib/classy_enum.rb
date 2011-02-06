require "classy_enum/base"
require "classy_enum/class_methods"
require "classy_enum/instance_methods"
require "classy_enum/attributes"

if Gem.available? 'formtastic'
  require 'formtastic'
  require 'classy_enum/semantic_form_builder'
end
