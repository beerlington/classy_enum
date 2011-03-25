module ClassyEnum
  class SemanticFormBuilder < Formtastic::SemanticFormBuilder # :nodoc: all
    def enum_select_input(method, options)
      enum_class = object.class.instance_variable_get(:@classy_enums)[method]

      raise Error.invalid_classy_enum_object(method) if enum_class.nil?

      options[:collection] = enum_class.select_options
      options[:selected] = object.send(method).to_s

      options[:include_blank] = false

      select_input(method, options)
    end
  end

  module Error # :nodoc: all
    def self.invalid_classy_enum_object(method)
      raise "#{method} is not a ClassyEnum object. Make sure you've added 'classy_enum_attr :#{method}' to your model"
    end
  end
end
