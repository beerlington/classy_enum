require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module TestEnum 
  OPTIONS = [:one, :two, :three]
  
  module Defaults
    def do_something?
      false
    end
  end

  include ClassyEnum
end

class TestEnumTwo
  def do_something?
    true
  end
end

describe ClassyEnum do

  TestEnum::OPTIONS.each do |option|
   it "should define a TestEnum#{option.to_s.capitalize} class" do
     Object.const_defined?("TestEnum#{option.to_s.capitalize}").should be_true
   end
  end
  
  it "should return an array of enums" do
    TestEnum.all.should == TestEnum::OPTIONS.map {|o| TestEnum.new(o) }
  end
  
  it "should return an array of enums for a select tag" do
    TestEnum.all_with_name.should == TestEnum::OPTIONS.map {|o| [TestEnum.new(o).name, TestEnum.new(o).to_s] }
  end
  
  it "should return a type error when adding an invalid option" do
    TestEnum.new(:invalid_option).class.should == TypeError
  end
  
  context "with a collection of enums" do
    before(:each) do
      @one = TestEnum.new(:one)
      @two = TestEnum.new(:two)
      @three = TestEnum.new(:three)

      @unordered = [@one, @three, @two]
    end
    
    it "should sort the enums" do
      @unordered.sort.should == [@one, @two, @three]
    end

    it "should find the max enum based on its order" do
      @unordered.max.should == @three
    end
  end
  
  it "should find an enum by symbol" do
    TestEnum.find(:one).class.should == TestEnumOne
  end
  
  it "should find an enum by string" do
    TestEnum.find("one").class.should == TestEnumOne
  end
  
end

describe "An ClassyEnumValue" do
  before(:each) { @enum = TestEnum.new(:one) }
  
  it "should have a name" do
    @enum.name.should == "One"
  end
  
  it "should inherit the Default methods" do
    @enum.do_something?.should be_false
  end
  
  it "should create the same instance with a string or symbol" do
    @enum_string = TestEnum.new("one")
    
    @enum.should == @enum_string
  end
end

describe "An ClassyEnumValue" do
  before(:each) { @enum = TestEnum.new(:two) }
  
  it "should override the Default methods" do
    @enum.do_something?.should be_true
  end
end