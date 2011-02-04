require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

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

  context "with a valid breed option" do
    before { @dog = Dog.new(:breed => :golden_retriever) }

    it "should have an enumerable breed" do
      @dog.breed.class.should == BreedGoldenRetriever
    end

    it "should know which member the enum is" do
      @dog.breed.is?(:golden_retriever).should be_true
    end

    it "should be valid with a valid option" do
      @dog.should be_valid
    end
  end

  context "with a nil breed option" do
    before { @dog = Dog.new(:breed => nil) }

    it "should return nil for the breed" do
      @dog.breed.should == ""
    end

    it "should be valid" do
      @dog.should be_valid
    end
  end

  context "with a blank breed option" do
    before { @dog = Dog.new(:breed => '') }

    it "should return '' for the breed" do
      @dog.breed.should == ""
    end

    it "should be valid" do
      @dog.should be_valid
    end
  end

  context "with an invalid breed option" do
    before { @dog = Dog.new(:breed => :golden_doodle) }

    it "should not be valid with an invalid option" do
      @dog.should_not be_valid
    end

    it "should have an error for the breed" do
      @dog.valid?
      @dog.errors.should include(:breed)
    end

    it "should have an error message containing the right options" do
      @dog.valid?
      @dog.errors[:breed].should include("must be one of #{Breed.all.map(&:to_sym).join(', ')}")
    end
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

end
