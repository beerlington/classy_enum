require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module TestEnum 
  OPTIONS = [:one, :two, :three]
  
  module InstanceMethods
    def test_instance_method?
      false
    end
  end

  module ClassMethods
    def test_class_method?
      false
    end
  end

  include ClassyEnum
end

class TestEnumTwo
  def self.test_class_method?
    true
  end

  def test_instance_method?
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
  
  it "should inherit the default instance methods" do
    @enum.test_instance_method?.should be_false
  end

  it "should inherit the default class methods" do
    TestEnumOne.test_class_method?.should be_false
  end
  
  it "should create the same instance with a string or symbol" do
    @enum_string = TestEnum.new("one")
    
    @enum.should == @enum_string
  end
end

describe "An ClassyEnumValue" do
  before(:each) { @enum = TestEnum.new(:two) }
  
  it "should override the default instance methods" do
    @enum.test_instance_method?.should be_true
  end

  it "should override the default class methods" do
    TestEnumTwo.test_class_method?.should be_true
  end
end
