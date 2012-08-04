module ClassyEnum
  module Collection
    extend ActiveSupport::Concern

    # Sort an array of elements based on the order they are defined
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
    #  @low = Priority.build(:low)
    #  @medium = Priority.build(:medium)
    #  @high = Priority.build(:high)
    #  priorities = [@low, @high, @medium]
    #  priorities.sort # => [@low, @medium, @high]
    #  priorities.max # => @high
    #  priorities.min # => @low
    def <=> other
      index <=> other.index
    end

    module ClassMethods
      def inherited(klass)
        if self == ClassyEnum::Base
          klass.class_attribute :enum_options
          klass.enum_options = []
        else
          enum_options << klass
          klass.instance_variable_set('@index', enum_options.size)
        end

        super
      end

      # Returns an array of all instantiated enums
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
      #  Priority.all # => [Priority::Low.new, Priority::Medium.new, Priority::High.new]
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
      #  class Priority::Low < Priority; end
      #  class Priority::ReallyHigh < Priority; end
      #
      #  Priority.select_options # => [["Low", "low"], ["Really High", "really_high"]]
      def select_options
        all.map {|e| [e.to_s.titleize, e.to_s] }
      end
    end

  end
end
