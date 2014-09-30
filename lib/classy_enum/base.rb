module ClassyEnum
  class SubclassNameError < StandardError; end

  class Base
    include Comparable
    include Conversion
    include Predicate
    include Translation
    include Collection

    attr_accessor :owner, :serialize_as_json, :allow_blank

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
            visitor_method = "visit_#{klass.name.split('::').join('_')}"

            Arel::Visitors::ToSql.class_eval do
              define_method visitor_method, lambda {|*values|
                values[0] = values[0].to_s
                begin
                  quoted(*values)
                rescue NoMethodError
                  quote(*values)
                end
              }
            end

            Arel::Visitors::DepthFirst.class_eval do
              define_method visitor_method, lambda {|*values|
                values[0] = values[0].to_s
                terminal(*values)
              }
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
        return value if value == nil
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
