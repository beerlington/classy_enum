module ClassyEnum
  class SubclassNameError < Exception; end

  class Base
    include Comparable
    include Conversion
    include Predicate
    include Collection

    class_attribute :base_class
    attr_accessor :owner, :serialize_as_json

    class << self
      def inherited(klass)
        if self == ClassyEnum::Base
          klass.base_class = klass
        else

          # Ensure subclasses follow expected naming conventions
          unless klass.name.start_with? "#{base_class.name}::"
            raise SubclassNameError, "subclass must be namespaced with #{base_class.name}::"
          end

          # Add visit_EnumMember methods to support validates_uniqueness_of with enum field
          Arel::Visitors::ToSql.class_eval do
            define_method "visit_#{klass.name.split('::').join('_')}", lambda {|value| quote(value.to_s) }
          end

          # Convert from MyEnumClass::NumberTwo to :number_two
          enum = klass.name.split('::').last.underscore.to_sym

          Predicate.define_predicate_method(klass, enum)

          klass.instance_variable_set('@option', enum)
        end

        super
      end

      # Build a new ClassyEnum child instance
      #
      # ==== Example
      #  # Create an Enum with some elements
      #  class Priority < ClassyEnum::Base
      #  end
      #
      #  class Priority::Low < Priority
      #  end
      #
      #  Priority.build(:low) # => Priority::Low.new
      def build(value, options={})
        return value if value.blank?

        # Return a TypeError if the build value is not a valid member
        unless all.map(&:to_sym).include? value.to_sym
          return TypeError.new("#{base_class} #{invalid_message}")
        end

        object = ("#{base_class}::#{value.to_s.camelize}").constantize.new
        object.owner = options[:owner]
        object.serialize_as_json = options[:serialize_as_json]
        object
      end

      # Returns a a message indicating which fields are valid
      #
      # ==== Example
      #  # Create an Enum with some elements
      #  class Priority < ClassyEnum::Base
      #  end
      #
      #  class Priority::Low < Priority; end
      #  class Priority::Medium < Priority; end
      #  class Priority::High < Priority; end
      #
      #  Priortiy.invalid_message # => must be low, medium, or high
      def invalid_message
        "must be #{all.to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')}"
      end

      # DSL setter method for overriding reference to enum owner (ActiveRecord model)
      #
      # ==== Example
      #  # Create an Enum with some elements
      #  class Priority < ClassyEnum::Base
      #    owner :alarm
      #  end
      #
      #  class Priority::High < Priority
      #    def send_alarm?
      #      alarm.enabled?
      #    end
      #  end
      def owner(owner)
        define_method owner, lambda { @owner }
      end
    end

  end
end
