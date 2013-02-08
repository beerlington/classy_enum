module ClassyEnum
  class InvalidDefault < StandardError; end

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
    def classy_enum_attr(attribute, options={})
      enum              = (options[:enum] || attribute).to_s.camelize.constantize
      allow_blank       = options[:allow_blank] || false
      allow_nil         = options[:allow_nil] || false
      serialize_as_json = options[:serialize_as_json] || false
      default           = options[:default]

      if default.present? && !default.in?(enum)
        raise InvalidDefault, "must be one of [#{enum.to_a.join(',')}]"
      end

      # Add ActiveRecord validation to ensure it won't be saved unless it's an option
      validates_inclusion_of attribute,
        :in          => enum,
        :allow_blank => allow_blank,
        :allow_nil   => allow_nil

      # Define getter method that returns a ClassyEnum instance
      define_method attribute do
        value = read_attribute(attribute) || default

        enum.build(value,
                   :owner             => self,
                   :serialize_as_json => serialize_as_json,
                   :allow_blank       => (allow_blank || allow_nil)
                  )
      end

      # Define setter method that accepts string, symbol, instance or class for member
      define_method "#{attribute}=" do |value|
        if value.class == Class && value < ClassyEnum::Base
          value = value.new.to_s
        elsif value.present?
          value = value.to_s
        end

        super(value)
      end
    end

  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send :extend, ClassyEnum::ActiveRecord
end
