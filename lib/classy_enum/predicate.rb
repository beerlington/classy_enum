module ClassyEnum
  module Predicate

    # Define attribute methods like two?
    def self.define_predicate_method(klass, enum)
      klass.base_class.class_eval do
        define_method "#{enum}?", -> { attribute?(enum) }
      end
    end

    protected

    # Determine if the enum attribute is a particular member.
    #
    # ==== Example
    #  # Create an Enum with some elements
    #  class Breed < ClassyEnum::Base
    #  end
    #
    # class Breed::GoldenRetriever < Breed; end
    # class Breed::Snoop < Breed; end
    #
    #  # Create an ActiveRecord class using the Breed enum
    #  class Dog < ActiveRecord::Base
    #    include ClassyEnum::ActiveRecord
    #
    #    classy_enum_attr :breed
    #  end
    #
    #  @dog = Dog.new(breed: :snoop)
    #  @dog.breed.snoop? # => true
    #  @dog.breed.golden_retriever? # => false
    def attribute?(attribute)
      self == attribute
    end
  end
end
