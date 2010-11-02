module ClassyEnum
  class SemanticFormBuilder < Formtastic::SemanticFormBuilder
    def enum_select_input(method, options)
      enum_class = object.send(method)
      
      if enum_class.nil?
        enum_class = method.to_s.capitalize.constantize rescue ::Error.invalid_classy_enum_object
        options[:collection] = enum_class.all_with_name
      else
        ::Error.invalid_classy_enum_object unless enum_class.respond_to? :base_class
        options[:collection] = enum_class.base_class.all_with_name
        options[:selected] = enum_class.to_s
      end
      
      options[:include_blank] = false
      
      select_input(method, options)
    end
  end
  
  module Error
    def invalid_classy_enum_object
      raise "#{method} does not refer to a defined ClassyEnum object"
    end
  end
end
