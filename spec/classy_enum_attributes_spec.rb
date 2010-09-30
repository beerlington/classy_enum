require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define(:version => 1) do
  create_table :dogs, :force => true do |t|
    t.string :breed
  end

  create_table :things, :force => true do |t|
    t.string :dog_breed
  end
end

module Breed
  OPTIONS = [:golden_retriever, :snoop]
  
  module Defaults
    
  end
  
  include ClassyEnum
end

class Dog < ActiveRecord::Base
  classy_enum_attr :breed
end

describe "A Dog" do
  
  before(:each) { @dog = Dog.new(:breed => :golden_retriever) }
  
  it "should have an enumerable breed" do
    @dog.breed.class.should == BreedGoldenRetriever
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
