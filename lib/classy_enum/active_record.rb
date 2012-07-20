module ClassyEnum
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
    def classy_enum_attr(*args)
      options = args.extract_options!

      attribute = args[0]

      enum              = (options[:enum] || attribute).to_s.camelize.constantize
      allow_blank       = options[:allow_blank] || false
      allow_nil         = options[:allow_nil] || false
      serialize_as_json = options[:serialize_as_json] || false

      error_message    = "must be #{enum.all.to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')}"

      # Add ActiveRecord validation to ensure it won't be saved unless it's an option
      validates_inclusion_of attribute,
        :in          => enum.all,
        :message     => error_message,
        :allow_blank => allow_blank,
        :allow_nil   => allow_nil

      # Define getter method that returns a ClassyEnum instance
      define_method attribute do
        enum.build(read_attribute(attribute),
                   :owner             => self,
                   :serialize_as_json => serialize_as_json,
                   :allow_blank       => (allow_blank || allow_nil)
                  )
      end

      # Define setter method that accepts either string or symbol for member
      define_method "#{attribute}=" do |value|
        value = value.to_s unless value.nil?
        super(value)
      end
    end

  end
end

ActiveRecord::Base.send :extend, ClassyEnum::ActiveRecord
