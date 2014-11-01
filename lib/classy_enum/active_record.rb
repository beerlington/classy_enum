module ClassyEnum
  class InvalidDefault < StandardError; end

  def self._normalize_value(value, default=nil, allow_blank=false) # :nodoc:
    if value.class == Class && value < ClassyEnum::Base
      value = value.new.to_s
    elsif value.present?
      value = value.to_s
    elsif value.blank? && allow_blank
      value
    else
      default
    end
  end

  def self._normalize_default(value, enum_class) # :nodoc:
    if value.present?
      if value.is_a? Proc
        value = value.call(enum_class)
      end

      unless enum_class.include? value
        raise InvalidDefault, "must be one of [#{enum_class.to_a.join(',')}]"
      end
    end

    value
  end

  module ActiveRecord
    def self.included(klass)
      klass.extend self
    end

    # Class macro used to associate an enum with an attribute on an ActiveRecord model.
    # This method is added to an ActiveRecord model when ClassEnum::ActiveRecord
    # is included. Accepts an argument for the enum class to be associated with
    # the model. ActiveRecord validation is automatically added to ensure
    # that a value is one of its pre-defined enum members.
    #
    # ==== Example
    #  # Associate an enum Priority with Alarm model's priority attribute
    #  class Alarm < ActiveRecord::Base
    #    include ClassyEnum::ActiveRecord
    #
    #    classy_enum_attr :priority
    #  end

    #  # Associate an enum Priority with Alarm model's alarm_priority attribute
    #  classy_enum_attr :alarm_priority, class_name: 'Priority'
    #
    #  # Allow enum value to be nil
    #  classy_enum_attr :priority, allow_nil: true
    #
    #  # Allow enum value to be blank
    #  classy_enum_attr :priority, allow_blank: true
    #
    #  # Specifying a default enum value
    #  classy_enum_attr :priority, default: 'low'
    def classy_enum_attr(attribute, options={})
      enum              = (options[:class_name] || options[:enum] || attribute).to_s.camelize.constantize
      allow_blank       = options[:allow_blank] || false
      allow_nil         = options[:allow_nil] || false
      default           = ClassyEnum._normalize_default(options[:default], enum)

      # Add ActiveRecord validation to ensure it won't be saved unless it's an option
      validates_inclusion_of attribute,
        in:          enum,
        allow_blank: allow_blank,
        allow_nil:   allow_nil

      # Use a module so that the reader methods can be overridden in classes and
      # use super to get the enum value.
      mod = Module.new do

        # Define getter method that returns a ClassyEnum instance
        define_method attribute do
          enum.build(read_attribute(attribute), owner: self)
        end

        # Define setter method that accepts string, symbol, instance or class for member
        define_method "#{attribute}=" do |value|
          value = ClassyEnum._normalize_value(value, default, (allow_nil || allow_blank))
          super(value)
        end

        define_method :save_changed_attribute do |attr_name, arg|
          if attribute.to_s == attr_name.to_s && !attribute_changed?(attr_name)
            arg = enum.build(arg)
            current_value = clone_attribute_value(:read_attribute, attr_name)

            if arg != current_value
              if respond_to?(:set_attribute_was, true)
                set_attribute_was(attr_name, enum.build(arg, owner: self))
              else
                changed_attributes[attr_name] = enum.build(current_value, owner: self)
              end
            end
          else
            super(attr_name, arg)
          end
        end
      end

      include mod

      # Initialize the object with the default value if it is present
      # because this will let you store the default value in the
      # database and make it searchable.
      if default.present?
        after_initialize do
          value = read_attribute(attribute)

          if (value.blank? && !(allow_blank || allow_nil)) || (value.nil? && !allow_nil)
            send("#{attribute}=", default)
          end
        end
      end

    end

  end
end
