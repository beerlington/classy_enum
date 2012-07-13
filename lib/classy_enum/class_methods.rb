module ClassyEnum
  module ClassMethods
    def inherited(klass)
      if self == ClassyEnum::Base
        klass.class_eval do
          class_attribute :enum_options, :base_class

          self.enum_options = []
          self.base_class   = klass

          attribute_method_suffix '?'
        end
      else

        # Add visit_EnumMember methods to support validates_uniqueness_of with enum field
        Arel::Visitors::ToSql.class_eval do
          define_method "visit_#{klass.name}", lambda {|value| quote(value.to_s) }
        end

        # Convert from MyEnumClassNumberTwo to :number_two
        enum = klass.name.gsub(klass.base_class.name, '').underscore.to_sym

        enum_options << enum
        define_attribute_method enum

        klass.class_eval do
          @index = enum_options.size
          @option = enum

          attr_accessor :owner, :serialize_as_json
        end
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
      return TypeError.new("#{self} #{invalid_message}") unless enum_options.include? value.to_sym

      object = ("#{self}#{value.to_s.camelize}").constantize.new
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
      enum_options.map {|e| build(e) }
    end

    # Returns a a message indicating which fields are valid
    def invalid_message
      "must be one of #{all.join(', ')}"
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

    # DSL setter method for reference to enum owner
    def owner(owner)
      define_method owner, lambda { @owner }
    end

  end
end
