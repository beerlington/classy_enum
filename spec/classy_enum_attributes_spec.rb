require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Dog < ActiveRecord::Base
  classy_enum_attr :breed
end

describe "A Dog Collection" do
  before(:each) do
    dog1 = Dog.new(:breed => :golden_retriever)
    dog2 = Dog.new(:breed => :snoop)

    @dogs = [dog1, dog2]
  end

  it "should sort by breed" do
    @dogs.sort_by(&:breed).should == @dogs
  end
end

describe "A Dog" do
  
  before(:each) { @dog = Dog.new(:breed => :golden_retriever) }
  
  it "should have an enumerable breed" do
    @dog.breed.class.should == BreedGoldenRetriever
  end

  it "should have a base class of Breed" do
    @dog.breed.base_class.should == Breed
  end
  
end

class Thing < ActiveRecord::Base
  classy_enum_attr :breed, :dog_breed 
end

describe "A Thing" do
  before(:each) { @thing = Thing.new(:dog_breed => :snoop) }

  it "should have an enumerable dog breed as breed" do
    @thing.dog_breed.class.should == BreedSnoop
  end

  it "should have a base class of Breed" do
    @thing.dog_breed.base_class.should == Breed
  end
end
