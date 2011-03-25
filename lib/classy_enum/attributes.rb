module ClassyEnum
  module Attributes

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
    #    classy_enum_attr :alarm_priority, :enum => :priority
    #  end
    def classy_enum_attr(*args)
      options = args.extract_options!

      attribute = args[0]
      enum = options[:enum] || attribute

      klass = enum.to_s.camelize.constantize

      self.instance_eval do

        # Store the enum class so it can be retrieved by Formtastic input builder
        @classy_enums ||= {}
        @classy_enums[attribute] = klass

        # Add ActiveRecord validation to ensure it won't be saved unless it's an option
        validates_inclusion_of attribute, :in => klass.all, :message => "must be one of #{klass.valid_options}"

        # Define getter method that returns a ClassyEnum instance
        define_method attribute do
          klass.build(super())
        end

        # Define setter method that accepts either string or symbol for member
        define_method "#{attribute}=" do |value|
          super(value.to_s)
        end

      end

    end

  end
end

ActiveRecord::Base.send :extend, ClassyEnum::Attributes
