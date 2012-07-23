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
    def enum_classes(*enums)
      ActiveSupport::Deprecation.warn('enum_classes is deprecated, and will be removed in ClassyEnum 3.0. It is no longer needed.', caller)
    end

    def inherited(klass)
      
      if self == ClassyEnum::Base
        klass.class_eval do
          class_attribute :enum_options, :base_class

          self.enum_options ||= []
          self.base_class = self
        end
        return
      end

      # Add visit_EnumMember methods to support validates_uniqueness_of with enum field
      Arel::Visitors::ToSql.class_eval do
        define_method "visit_#{klass.name}", lambda {|value| quote(value.to_s) }
      end

      if klass.name.start_with? "#{base_class.name}::"
        enum = klass.name.split('::').last.underscore.to_sym
      else
        ActiveSupport::Deprecation.warn("The enum class name #{klass} is deprecated. ClassyEnum 3.0 will require subclasses to use the parent class as a namespace. Change it to #{base_class}::#{klass.name.gsub(base_class.name, '')}", caller)
        enum = klass.name.gsub(klass.base_class.name, '').underscore.to_sym
      end
      
      self.enum_options << enum
      index = self.enum_options.index(enum) + 1
      
      self.class_eval do
        define_method "#{enum}?".to_sym, lambda { to_s == enum.to_s }
      end

      klass.class_eval do
        @index = index
        @option = enum
        
        attr_accessor :owner, :serialize_as_json
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
    def build(value, options={})
      return value if value.blank?
      return TypeError.new("Valid #{self} options are #{self.valid_options}") unless self.enum_options.include? value.to_sym

      # Temp hack until 3.0 to allow both namespaced and non-namespaced classes
      begin
        klass = "#{self}::#{value.to_s.camelize}".constantize
      rescue NameError
        klass = "#{self}#{value.to_s.camelize}".constantize
      end

      object = klass.new
      object.owner = options[:owner]
      object.serialize_as_json = options[:serialize_as_json]
      object
    end

    def find(value, options={})
      ActiveSupport::Deprecation.warn("find is deprecated, and will be removed in ClassyEnum 3.0. Use build(:member) instead.", caller)
      build(value, options)
    end

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
      self.enum_options.map {|e| build(e) }
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
      all.map {|e| [e.to_s.titleize, e.to_s] }
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
      ActiveSupport::Deprecation.warn("valid_options is deprecated, and will be removed in ClassyEnum 3.0. Use all.join(', ') instead.", caller)
      self.enum_options.map(&:to_s).join(', ')
    end

    private

    # DSL setter method for reference to enum owner
    def owner(owner)
      define_method owner, lambda { @owner }
    end

  end
end
