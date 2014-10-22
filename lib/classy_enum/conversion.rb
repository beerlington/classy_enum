module ClassyEnum
  module Conversion

    # Returns an integer representing the order that this element was defined in.
    # Also used internally for sorting.
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
    #  @priority = Priority::Medium.new
    #  @priority.to_i # => 2
    def to_i
      self.class.instance_variable_get('@index')
    end

    alias :index :to_i

    # Returns the name or string corresponding to element
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
    #  @priority = Priority::Low.new
    #  @priority.to_s # => 'low'
    def to_s
      option.to_s
    end

    # Returns a Symbol corresponding to a string representation of element,
    # creating the symbol if it did not previously exist
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
    #  @priority = Priority::Low.new
    #  @priority.to_sym # => :low
    def to_sym
      to_s.to_sym
    end

    # Overrides as_json to remove owner reference recursion issues
    def as_json(options=nil)
      to_s
    end

    private

    def option
      self.class.instance_variable_get(:@option)
    end

  end
end
