module ClassyEnum
  class SubclassNameError < StandardError; end

  class Base
    include Comparable
    include Conversion
    include Predicate
    include Translation
    include Collection

    attr_accessor :owner, :allow_blank

    def base_class
      self.class.base_class
    end

    class << self
      def base_class
        @base_class ||= superclass.base_class
      end

      def base_class=(klass)
        @base_class = klass
      end

      def inherited(klass)
        if self == ClassyEnum::Base
          klass.base_class = klass
        else

          # Ensure subclasses follow expected naming conventions
          unless klass.name.start_with? "#{base_class.name}::"
            raise SubclassNameError, "subclass must be namespaced with #{base_class.name}::"
          end

          # Convert from MyEnumClass::NumberTwo to :number_two
          enum = klass.name.split('::').last.underscore.to_sym

          Predicate.define_predicate_method(klass, enum)

          klass.instance_variable_set('@option', enum)
        end

        super
      end

      # Used internally to build a new ClassyEnum child instance
      # It is preferred that you use ChildClass.new instead
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
      #  Priority.build(:invalid_option) # => :invalid_option
      def build(value, options={})
        object = find(value)

        if object.nil?
          value
        else
          object.owner = options[:owner]
          object
        end
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
        define_method owner, -> { @owner }
      end
    end
  end
end
