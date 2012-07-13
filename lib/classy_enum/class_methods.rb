module ClassyEnum
  class SubclassNameError < Exception; end

  module ClassMethods
    def inherited(klass)
      if self == ClassyEnum::Base
        klass.enum_options = []
        klass.base_class   = klass
      else

        # Ensure subclasses follow expected naming conventions
        unless klass.name.start_with? base_class.name
          raise SubclassNameError, "subclass name must start with #{base_class.name}"
        end

        # Add visit_EnumMember methods to support validates_uniqueness_of with enum field
        Arel::Visitors::ToSql.class_eval do
          define_method "visit_#{klass.name}", lambda {|value| quote(value.to_s) }
        end

        # Convert from MyEnumClassNumberTwo to :number_two
        enum = klass.name.gsub(klass.base_class.name, '').underscore.to_sym

        enum_options << klass

        # Define attribute methods like two?
        base_class.class_eval do
          define_method "#{enum}?", lambda { attribute?(enum.to_s) }
        end

        klass.class_eval do
          @index = enum_options.size
          @option = enum
        end
      end
    end

    # Build a new ClassyEnum child instance
    #
    # ==== Example
    #  # Create an Enum with some elements
    #  class Priority < ClassyEnum::Base
    #  end
    #
    #  class PriorityLow < Priority
    #  end
    #
    #  Priority.build(:low) # => PriorityLow.new
    def build(value, options={})
      return value if value.blank?

      # Return a TypeError if the build value is not a valid member
      unless all.map(&:to_sym).include? value.to_sym
        return TypeError.new("#{base_class} #{invalid_message}")
      end

      object = ("#{base_class}#{value.to_s.camelize}").constantize.new
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
    #  end
    #
    # class PriorityLow < Priority; end
    # class PriorityMedium < Priority; end
    # class PriorityHigh < Priority; end
    #
    #  Priority.all # => [PriorityLow.new, PriorityMedium.new, PriorityHigh.new]
    def all
      enum_options.map(&:new)
    end

    # Returns a 2D array for Rails select helper options.
    # Also used internally for Formtastic support
    #
    # ==== Example
    #  # Create an Enum with some elements
    #  class Priority < ClassyEnum::Base
    #  end
    #
    # class PriorityLow < Priority; end
    # class PriorityReallyHigh < Priority; end
    #
    #  Priority.select_options # => [["Low", "low"], ["Really High", "really_high"]]
    def select_options
      all.map {|e| [e.name, e.to_s] }
    end

    # Returns a a message indicating which fields are valid
    def invalid_message
      "must be one of #{all.join(', ')}"
    end

    # DSL setter method for reference to enum owner
    def owner(owner)
      define_method owner, lambda { @owner }
    end

  end
end
