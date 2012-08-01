module ClassyEnum
  class SubclassNameError < Exception; end

  class Base
    include Comparable
    include Conversion
    include Predicate
    include Collection

    class_attribute :base_class
    attr_accessor :owner, :serialize_as_json, :allow_blank

    class << self
      def inherited(klass)
        if self == ClassyEnum::Base
          klass.base_class = klass
        else

          # Ensure subclasses follow expected naming conventions
          unless klass.name.start_with? "#{base_class.name}::"
            raise SubclassNameError, "subclass must be namespaced with #{base_class.name}::"
          end

          if klass.kind_of? ActiveRecord::Base
            # Add visit_EnumMember methods to support validates_uniqueness_of with enum field
            # This is due to a bug in Rails where it uses the method result as opposed to the
            # database value for validation scopes. A fix will be released in Rails 4, but
            # this will remain until Rails 3.x is no longer prevalent.
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
        return value if value.blank? && options[:allow_blank]

        # Return the value if it is not a valid member
        return value unless all.map(&:to_s).include? value.to_s

        object = "#{base_class}::#{value.to_s.camelize}".constantize.new
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
    end

  end
end
