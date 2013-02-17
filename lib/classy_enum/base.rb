module ClassyEnum
  class SubclassNameError < Exception; end

  class Base
    include Comparable
    include Conversion
    include Predicate
    include Translation
    include Collection

    class_attribute :base_class
    attr_accessor :owner, :serialize_as_json, :allow_blank

    class << self
      def inherited(klass)
        return if klass.anonymous?

        if self == ClassyEnum::Base
          klass.base_class = klass
        else

          # Ensure subclasses follow expected naming conventions
          unless klass.name.start_with? "#{base_class.name}::"
            raise SubclassNameError, "subclass must be namespaced with #{base_class.name}::"
          end

          # Add visit_EnumMember methods to support validates_uniqueness_of with enum field
          # This is due to a bug in Rails where it uses the method result as opposed to the
          # database value for validation scopes. A fix will be released in Rails 4, but
          # this will remain until Rails 3.x is no longer prevalent.
          if defined?(Arel::Visitors::ToSql)
            Arel::Visitors::ToSql.class_eval do
              define_method "visit_#{klass.name.split('::').join('_')}", lambda {|value| quote(value.to_s) }
            end
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

        if object.nil? || (options[:allow_blank] && object.nil?)
          if value.blank?
            object = build_null_object(value)
          else
            return value
          end
        end

        object.owner = options[:owner]
        object.serialize_as_json = options[:serialize_as_json]
        object.allow_blank = options[:allow_blank]
        object
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

      private

      # Subclass the base class and make it behave like the value that it is
      def build_null_object(value)
        Class.new(base_class) {
          @option = value
          @index = 0
          delegate :blank?, :nil?, :to => :option
        }.new
      end
    end

  end
end
