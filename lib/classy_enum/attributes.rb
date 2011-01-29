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
    #    classy_enum_attr :priority, :alarm_priority
    #  end
    def classy_enum_attr(klass, method=nil)

      method ||= klass

      klass = klass.to_s.camelize.constantize

      self.instance_eval do

        # Add ActiveRecord validation to ensure it won't be saved unless it's an option
        validates_each [method], :allow_nil => true do |record, attr_name, value|
          record.errors.add(attr_name, "must be one of #{klass.all.map(&:to_sym).join(', ')}") unless klass.all.map(&:to_s).include? value.to_s
        end

        # Define getter method that returns a ClassyEnum instance
        define_method method do
          klass.build(super())
        end

        # Define setter method that accepts either string or symbol for member
        define_method "#{method}=" do |value|
          super(value.to_s)
        end

      end

    end

  end
end

ActiveRecord::Base.send :extend, ClassyEnum::Attributes
