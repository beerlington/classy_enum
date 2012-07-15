module ClassyEnum
  module Predicate

    # Define attribute methods like two?
    def self.define_predicate_method(klass, enum)
      klass.base_class.class_eval do
        define_method "#{enum}?", lambda { attribute?(enum.to_s) }
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
    # class BreedGoldenRetriever < Priority; end
    # class BreedSnoop < Priority; end
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
  end
end
