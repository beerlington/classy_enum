module ClassyEnum

  class Base

    # Macro for defining enum members within a ClassyEnum class.
    # Accepts an array of symbols or strings which are converted to
    # ClassyEnum members as descents of their parent class.
    #
    # ==== Example
    #  # Define an enum called Priority with three child classes
    #  class Priority < ClassyEnum::Base
    #    enum_classes :low, :medium, :high
    #  end
    #
    #  The child classes will be defined with the following constants:
    #  PriorityLow, PriorityMedium, and PriorityHigh
    #
    #  These child classes can be instantiated with either:
    #  Priority.build(:low) or PriorityLow.new
    #
    def self.enum_classes(*options)
      self.const_set("OPTIONS", options) unless self.const_defined? "OPTIONS"

      self.extend ClassyEnum::ClassMethods
      self.send(:include, ClassyEnum::InstanceMethods)
      self.send(:include, Comparable)

      options.each_with_index do |option, index|

        klass = Class.new(self) do
          @index = index + 1
          @option = option

          def initialize
            @to_s = self.class.instance_variable_get('@option').to_s
            @index = self.class.instance_variable_get('@index')
          end

          # Define methods to test member type (ie member.option?)
          options.each do |o|
            self.send(:define_method, "#{o}?", lambda { o == option })
          end

        end

        klass_name = "#{self}#{option.to_s.camelize}"
        Object.const_set(klass_name, klass) unless Object.const_defined? klass_name
      end
    end
  end

end
