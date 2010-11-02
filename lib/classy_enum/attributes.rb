module ClassyEnum
  module Attributes

    def classy_enum_attr(klass, method=nil)

      method ||= klass

      klass = klass.to_s.camelize.constantize

      # Add ActiveRecord validation to ensure it won't be saved unless it's an option
      self.send(:validates_inclusion_of, method, :in => klass.all, :allow_nil => true)

      self.instance_eval do

        # Define getter method
        define_method method do
          klass.new(super())
        end

        # Define setter method
        define_method "#{method}=" do |value|
          super(value.to_s)
        end

      end

    end

  end
end

ActiveRecord::Base.send :extend, ClassyEnum::Attributes