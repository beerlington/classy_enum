module ClassyEnum
  module ClassMethods

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
    def enum_classes(*options)
      self.const_set("OPTIONS", options) unless self.const_defined? "OPTIONS"

      options.each_with_index do |option, index|

        klass = Class.new(self) do
          @index = index + 1
          @option = option

          # Use ActiveModel::AttributeMethods to define attribute? methods
          attribute_method_suffix '?'
          define_attribute_methods options

          def initialize
            @to_s = self.class.instance_variable_get('@option').to_s
            @index = self.class.instance_variable_get('@index')
          end

        end

        klass_name = "#{self}#{option.to_s.camelize}"
        Object.const_set(klass_name, klass) unless Object.const_defined? klass_name
      end
    end

    # Build a new ClassyEnum child instance
    #
    # ==== Example
    #  # Create an Enum with some elements
    #  class Priority < ClassyEnum::Base
    #    enum_classes :low, :medium, :high
    #  end
    #
    #  Priority.build(:low) # => PriorityLow.new
    def build(option)
      return option if option.blank?
      return TypeError.new("Valid #{self} options are #{self.valid_options}") unless self::OPTIONS.include? option.to_sym
      Object.const_get("#{self}#{option.to_s.camelize}").new
    end

    alias :find :build

    # Returns an array of all instantiated enums
    #
    # ==== Example
    #  # Create an Enum with some elements
    #  class Priority < ClassyEnum::Base
    #    enum_classes :low, :medium, :high
    #  end
    #
    #  Priority.all # => [PriorityLow.new, PriorityMedium.new, PriorityHigh.new]
    def all
      self::OPTIONS.map {|e| build(e) }
    end

    # Returns a 2D array for Rails select helper options.
    # Also used internally for Formtastic support
    #
    # ==== Example
    #  # Create an Enum with some elements
    #  class Priority < ClassyEnum::Base
    #    enum_classes :low, :really_high
    #  end
    #
    #  Priority.select_options # => [["Low", "low"], ["Really High", "really_high"]]
    def select_options
      all.map {|e| [e.name, e.to_s] }
    end

    # Returns a comma separated list of valid enum options.
    # Also used internally for ActiveRecord model validation error messages
    #
    # ==== Example
    #  # Create an Enum with some elements
    #  class Priority < ClassyEnum::Base
    #    enum_classes :low, :medium, :high
    #  end
    #
    #  Priority.valid_options # => "low, medium, high"
    def valid_options
      self::OPTIONS.map(&:to_s).join(', ')
    end

  end
end
