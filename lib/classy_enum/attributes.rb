module ClassyEnum
  module Attributes

    def classy_enum_attr(klass, method=nil)

      method ||= klass

      klass = klass.to_s.camelize.constantize

      self.instance_eval do

        # Add ActiveRecord validation to ensure it won't be saved unless it's an option
        validates_each [method], :allow_nil => true do |record, attr_name, value|
          record.errors.add(attr_name, "must be one of #{klass.all.map(&:to_sym).join(', ')}") unless klass.all.map(&:to_s).include? value.to_s
        end

        # Define getter method
        define_method method do
          klass.build(super())
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
