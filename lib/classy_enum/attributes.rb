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
    def classy_enum_attr(*options)
    	enum = options[0]
    	attribute = enum
    	allow_blank = false
    	allow_nil = false
    	
    	options[1..-1].each do |o|
    		if o.is_a? Symbol
    			attribute = o	
    		elsif o.is_a? Hash
    			allow_blank = o[:allow_blank] || false
    			allow_nil = o[:allow_nil] || false
    		end
    	end
    	
      klass = enum.to_s.camelize.constantize

      self.instance_eval do

        # Add ActiveRecord validation to ensure it won't be saved unless it's an option
        validates_inclusion_of attribute, :in => klass.all, :message => "must be one of #{klass.valid_options}",
        																	:allow_blank => allow_blank, :allow_nil => allow_nil
        																	

        # Define getter method that returns a ClassyEnum instance
        define_method attribute do
          klass.build(super())
        end

        # Define setter method that accepts either string or symbol for member
        define_method "#{attribute}=" do |value|
          value = value.to_s if value.is_a? Symbol
          super(value)
        end

      end

    end

  end
end

ActiveRecord::Base.send :extend, ClassyEnum::Attributes
