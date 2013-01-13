def enum name, parent_class = nil, &block
  clazz_name = name.to_s.camelize 
  if parent_class != :none
    context = self.inspect == 'main' ? Object : self
    parent_class ||= context unless context == Object
  else
    context = Object
    parent_class = nil
  end
  parent_class ||= ::ClassyEnum::Base

  raise "Bad superclass: #{parent_class}" unless parent_class.kind_of?(Class)

  klass = Class.new(parent_class)  
  
  context.const_set clazz_name, klass

  klass = context.const_get(clazz_name)
  puts "klass: #{klass} - #{clazz_name}"

  unless context == Object
    klass.class_eval do   
      puts "klass: #{klass}"

      if parent_class == ClassyEnum::Base
        klass.base_class = klass
        klass.send :include, ClassyEnum::ValidValues
      end
      return unless klass && klass.name

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
      enum = klass.name.split('::').last.underscore.to_sym

      klass.valid_values << enum

      ClassyEnum::Predicate.define_predicate_method(klass, enum)

      klass.instance_variable_set('@option', enum)
    end
  end

  if block_given?
    klass.class_eval &block
  end
end

def enums *names
  names.flatten.compact.each {|name| enum name }
end

def enum_for name, list
  enum name, :none do
    enums list
  end
end