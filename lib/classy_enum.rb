require "classy_enum/attributes"

if Gem.available? 'formtastic'
  require 'formtastic'
  require 'classy_enum/semantic_form_builder'
end

module ClassyEnum

  class Base
    def self.enum_classes(*options)
      self.send(:attr_reader, :enum_classes)

      self.const_set("OPTIONS", options) unless self.const_defined? "OPTIONS"

      self.extend ClassMethods

      options.each_with_index do |option, index|

        klass = Class.new(self) do
          include InstanceMethods

          attr_reader :to_s, :to_sym, :index

          @index = index + 1
          @option = option

          def initialize
            @to_s = self.class.instance_variable_get('@option').to_s
            @to_sym = @to_s.to_sym
            @index = self.class.instance_variable_get('@index')
          end

        end

        klass_name = "#{self}#{option.to_s.camelize}"
        Object.const_set(klass_name, klass) unless Object.const_defined? klass_name
      end
    end
  end

  module ClassMethods

    # Build a new ClassyEnum child instance
    #
    # ==== Example
    #  # Create an Enum with some elements
    #  class Priority < ClassyEnum::Base
    #    enum_classes :low, :medium, :high
    #  end
    #
    #  Priority.build(:low) # => PriorityLow.new
    def build(option)
      return option if option.blank?
      return TypeError.new("Valid #{self} options are #{self.valid_options}") unless self::OPTIONS.include? option.to_sym
      Object.const_get("#{self}#{option.to_s.camelize}").new
    end

    alias :find :build

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
      self::OPTIONS.map {|e| build(e) }
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

    # Returns a comma separated list of valid enum options.
    # Also used internally for ActiveRecord model validation error messages
    #
    # ==== Example
    #  # Create an Enum with some elements
    #  class Priority < ClassyEnum::Base
    #    enum_classes :low, :medium, :high
    #  end
    #
    #  Priority.valid_options # => "low, medium, high"
    def valid_options
      self::OPTIONS.map(&:to_s).join(', ')
    end

  end

  module InstanceMethods
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
      @to_s.titleize
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
      @index <=> other.index
    end

    # Determine if the enum attribute is a particular member.
    # Accepts a symbol, string or class constant representing a member
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
    #  @dog.breed.is? :snoop # => true
    #  @dog.breed.is? 'snoop' # => true
    #  @dog.breed.is? BreedSnoop # => true
    #  @dog.breed.is? :golden_retriever # => false
    def is?(obj)
      # Instantiate object if it's a ClassyEnum child
      obj = obj.new if obj.is_a?(Class) && obj.ancestors.include?(ClassyEnum::Base)

      obj.to_s == to_s
    end

  end

end
