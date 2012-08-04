def enum name, parent_class = nil, &block
  clazz_name = name.to_s.camelize      
  context = self.inspect == 'main' ? Object : self
  parent_class ||= context unless context == Object
  parent_class ||= ::ClassyEnum::Base

  klass = Class.new(parent_class)  
  
  context.const_set clazz_name, klass

  klass = context.const_get(clazz_name)
  unless context == Object
    klass.class_eval do      
      if parent_class == ClassyEnum::Base
        klass.class_attribute :enum_options
        klass.enum_options = []
      else
        enum_options << klass
        klass.instance_variable_set('@index', enum_options.size)
      end


      # Add visit_EnumMember methods to support validates_uniqueness_of with enum field
      # This is due to a bug in Rails where it uses the method result as opposed to the
      # database value for validation scopes. A fix will be released in Rails 4, but
      # this will remain until Rails 3.x is no longer prevalent.
      if defined?(Arel::Visitors::ToSql)
        Arel::Visitors::ToSql.class_eval do
          define_method "visit_#{klass.name.split('::').join('_')}", lambda {|value| quote(value.to_s) }
        end
      end

      # Convert from MyEnumClass::NumberTwo to :number_two
      enum = name

      ClassyEnum::Predicate.define_predicate_method(klass, enum)

      klass.instance_variable_set('@option', enum)
    end
  end

  if block_given?
    klass.class_eval &block
  end
end

def enums *names
  names.each {|name| enum name }
end