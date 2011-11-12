module ClassyEnum
  module InstanceMethods
    # Returns an integer representing the order that this element was defined in.
    # Also used internally for sorting.
    #
    # ==== Example
    #  # Create an Enum with some elements
    #  class Priority < ClassyEnum::Base
    #    enum_classes :low, :medium, :high
    #  end
    #
    #  @priority = PriorityMedium.new
    #  @priority.index # => 2
    def index
      self.class.instance_variable_get('@index')
    end

    alias :to_i :index

    # Returns the name or string corresponding to element
    #
    # ==== Example
    #  # Create an Enum with some elements
    #  class Priority < ClassyEnum::Base
    #    enum_classes :low, :medium, :high
    #  end
    #
    #  @priority = PriorityLow.new
    #  @priority.to_s # => 'low'
    def to_s
      self.class.instance_variable_get('@option').to_s
    end

    # Returns a Symbol corresponding to a string representation of element,
    # creating the symbol if it did not previously exist
    #
    # ==== Example
    #  # Create an Enum with some elements
    #  class Priority < ClassyEnum::Base
    #    enum_classes :low, :medium, :high
    #  end
    #
    #  @priority = PriorityLow.new
    #  @priority.to_sym # => :low
    def to_sym
      to_s.to_sym
    end

    # Returns string representing enum in Rails titleize format
    #
    # ==== Example
    #  # Create an Enum with some elements
    #  class Priority < ClassyEnum::Base
    #    enum_classes :low, :medium, :high, :really_high
    #  end
    #
    #  @priority = Priority.build(:really_high)
    #  @priority.name # => "Really High"
    def name
      to_s.titleize
    end

    # Sort an array of elements based on the order they are defined
    #
    # ==== Example
    #  # Create an Enum with some elements
    #  class Priority < ClassyEnum::Base
    #    enum_classes :low, :medium, :high
    #  end
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

    # Used by ActiveRecord::PredicateBuilder when building from a hash
    def is_a?(klass)
      return true if klass == ActiveRecord::Base
      super(klass)
    end

    # Used by ActiveRecord::PredicateBuilder when building from a hash
    def id
      to_s
    end

    # Overrides as_json to remove owner reference recursion issues
    def as_json(options=nil)
      return to_s unless serialize_as_json
      json = super(options)
      json.delete('owner')
      json.delete('serialize_as_json')
      json
    end

  protected

    # Determine if the enum attribute is a particular member.
    #
    # ==== Example
    #  # Create an Enum with some elements
    #  class Breed < ClassyEnum::Base
    #    enum_classes :golden_retriever, :snoop
    #  end
    #
    #  # Create an ActiveRecord class using the Breed enum
    #  class Dog < ActiveRecord::Base
    #    classy_enum_attr :breed
    #  end
    #
    #  @dog = Dog.new(:breed => :snoop)
    #  @dog.breed.snoop? # => true
    #  @dog.breed.golden_retriever? # => false
    def attribute?(attribute)
      to_s == attribute
    end

  private

    # Used by attribute methods
    def attributes
      []
    end

  end
end
