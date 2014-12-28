module ClassyEnum
  module Collection
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
      if other.is_a?(Symbol) || other.is_a?(String)
        other = self.class.find(other)
      elsif other.is_a?(Class)
        other = other.new
      end

      if other.is_a? ClassyEnum::Base
        index <=> other.index
      else
        nil
      end
    end

    def enum_options
      self.class.enum_options
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      include Enumerable
      alias all to_a

      def inherited(klass)
        if self == ClassyEnum::Base
          klass.class_eval do
            def self.enum_options
              @enum_options ||= superclass.enum_options
            end

            def self.enum_options=(options)
              @enum_options = options
            end
          end
          klass.enum_options = []
        else
          enum_options << klass
          klass.instance_variable_set('@index', enum_options.size)
        end

        super
      end

      # Iterates over instances of each enum in the collection
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
      #  Priority.each do |priority|
      #    puts priority # => 'Low', 'Medium', 'High'
      #  end
      def each
        enum_options.each {|e| yield e.new }
      end

      # Returns the last enum instance in the collection
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
      #  Priority.last # => Priority::High
      def last
        to_a.last
      end

      # Finds an enum instance by symbol, string, or block.
      #
      # If a block is given, it passes each entry in enum to block, and returns
      # the first enum for which block is not false. If no enum matches, it
      # returns nil.
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
      #  Priority.find(:high) # => Priority::High.new
      #  Priority.find('high') # => Priority::High.new
      #  Priority.find {|e| e.to_sym == :high } # => Priority::High.new
      def find(key=nil)
        if block_given?
          super
        elsif map(&:to_s).include? key.to_s
          super { |e| e.to_s == key.to_s }
        end
      end

      alias detect find
      alias [] find

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
        map {|e| [e.text, e.to_s] }
      end
    end

  end
end
