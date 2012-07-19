module ClassyEnum
  module ActiveRecord

    # Class macro used to associate an enum with an attribute on an ActiveRecord model.
    # This method is automatically added to all ActiveRecord models when the classy_enum gem
    # is installed. Accepts an argument for the enum class to be associated with
    # the model. If the enum class name is different than the field name, then an optional
    # field name can be passed. ActiveRecord validation is automatically added to ensure
    # that a value is one of its pre-defined enum members.
    #
    # ==== Example
    #  # Associate an enum Priority with Alarm model's priority attribute
    #  class Alarm < ActiveRecord::Base
    #    classy_enum_attr :priority
    #  end
    #
    #  # Associate an enum Priority with Alarm model's alarm_priority attribute
    #  class Alarm < ActiveRecord::Base
    #    classy_enum_attr :alarm_priority, :enum => 'Priority'
    #  end
    def classy_enum_attr(*args)
      options = args.extract_options!

      attribute = args[0]

      enum              = (options[:enum] || attribute).to_s.camelize.constantize
      allow_blank       = options[:allow_blank] || false
      allow_nil         = options[:allow_nil] || false
      serialize_as_json = options[:serialize_as_json] || false

      reader_method     = attribute.to_s
      reader_method += "_#{options[:suffix]}" if options.has_key?(:suffix)

      valid_attributes = reader_method == attribute.to_s ? enum.all : enum.all.map(&:to_s)
      error_message    = "must be #{enum.all.to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')}"

      # Add ActiveRecord validation to ensure it won't be saved unless it's an option
      validates_inclusion_of attribute,
        :in          => valid_attributes,
        :message     => error_message,
        :allow_blank => allow_blank,
        :allow_nil   => allow_nil

      # Define getter method that returns a ClassyEnum instance
      define_method reader_method do
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
