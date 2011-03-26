module ClassyEnum
  class SemanticFormBuilder < Formtastic::SemanticFormBuilder # :nodoc: all
    def enum_select_input(method, options)
      raise Error.invalid_classy_enum_object(method) unless object.respond_to? "#{method}_options"

      enum_options = object.send("#{method}_options")
      enum_class = enum_options[:enum].to_s.classify.constantize

      options[:collection] = enum_class.select_options
      options[:selected] = object.send(method).to_s
      options[:include_blank] = enum_options[:allow_blank] || enum_options[:allow_nil]

      select_input(method, options)
    end
  end

  module Error # :nodoc: all
    def self.invalid_classy_enum_object(method)
      raise "#{method} is not a ClassyEnum object. Make sure you've added 'classy_enum_attr :#{method}' to your model"
    end
  end
end
