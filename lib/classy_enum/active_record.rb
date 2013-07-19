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

    # Class macro used to associate an enum with an attribute on an ActiveRecord model.
    # This method is automatically added to all ActiveRecord models when the classy_enum gem
    # is installed. Accepts an argument for the enum class to be associated with
    # the model. ActiveRecord validation is automatically added to ensure
    # that a value is one of its pre-defined enum members.
    #
    # ==== Example
    #  # Associate an enum Priority with Alarm model's priority attribute
    #  class Alarm < ActiveRecord::Base
    #    classy_enum_attr :priority
    #  end
    #
    #  # Associate an enum Priority with Alarm model's alarm_priority attribute
    #  classy_enum_attr :alarm_priority, :enum => 'Priority'
    #
    #  # Allow enum value to be nil
    #  classy_enum_attr :priority, :allow_nil => true
    #
    #  # Allow enum value to be blank
    #  classy_enum_attr :priority, :allow_blank => true
    #
    #  # Specifying a default enum value
    #  classy_enum_attr :priority, :default => 'low'
    def classy_enum_attr(attribute, options={})
      enum              = (options[:enum] || attribute).to_s.camelize.constantize
      allow_blank       = options[:allow_blank] || false
      allow_nil         = options[:allow_nil] || false
      serialize_as_json = options[:serialize_as_json] || false
      default           = ClassyEnum._normalize_default(options[:default], enum)

      # Add ActiveRecord validation to ensure it won't be saved unless it's an option
      validates_inclusion_of attribute,
        :in          => enum,
        :allow_blank => allow_blank,
        :allow_nil   => allow_nil

      # Define getter method that returns a ClassyEnum instance
      define_method attribute do
        value = read_attribute(attribute)
        enum.build(value,
                   :owner             => self,
                   :serialize_as_json => serialize_as_json,
                   :allow_blank       => (allow_blank || allow_nil)
                  )
      end

      # Define setter method that accepts string, symbol, instance or class for member
      define_method "#{attribute}=" do |value|
        value = ClassyEnum._normalize_value(value, default, (allow_nil || allow_blank))
        super(value)
      end

      # Initialize the object with the default value if it is present
      # because this will let you store the default value in the
      # database and make it searchable.
      if default.present?
        after_initialize do
          value = read_attribute(attribute)

          if (value.blank? && !allow_blank) && (value.nil? && !allow_nil)
            send("#{attribute}=", value)
          end
        end
      end

    end

  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send :extend, ClassyEnum::ActiveRecord
end
