module ClassyEnum
  class SemanticFormBuilder < Formtastic::SemanticFormBuilder
    def enum_select_input(method, options)
      enum_class = object.send(method)

      if enum_class.nil?
        enum_class = method.to_s.capitalize.constantize rescue Error.invalid_classy_enum_object(method)
        options[:collection] = enum_class.select_options
      else
        Error.invalid_classy_enum_object unless enum_class.respond_to? :enum_classes
        options[:collection] = enum_class.class.superclass.select_options
        options[:selected] = enum_class.to_s
      end
      
      options[:include_blank] = false
      
      select_input(method, options)
    end
  end
  
  module Error
    def self.invalid_classy_enum_object(method)
      raise "#{method} is not a ClassyEnum object"
    end
  end
end
