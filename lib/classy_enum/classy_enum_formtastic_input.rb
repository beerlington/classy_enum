module ClassyEnumFormtasticInput
  class SemanticFormBuilder < Formtastic::SemanticFormBuilder
    def enum_select_input(method, options)
      enum_class = object.send(method)

      raise "#{method} does not refer to a defined ClassyEnum object" unless enum_class.respond_to? :base_class

      options[:collection] = enum_class.base_class.all_with_name
      options[:selected] = enum_class.to_s

      select_input(method, options)
    end
  end
end
