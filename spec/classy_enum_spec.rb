require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class TestEnum 
  extend ClassyEnum

  enum_classes :one, :two, :three
  
  def self.test_class_method?
    false
  end

  def test_instance_method?
    false
  end
end

class TestEnumTwo
  def self.test_class_method?
    true
  end

  def test_instance_method?
    true
  end
end

# Used to assert include and extend behave identically
class IncludedEnum
  include ClassyEnum

  enum_classes :one, :two, :three
end

describe TestEnum do

  TestEnum::OPTIONS.each do |option|
   it "should define a TestEnum#{option.to_s.capitalize} class" do
     Object.const_defined?("TestEnum#{option.to_s.capitalize}").should be_true
   end
  end
  
  it "should return an array of enums" do
    TestEnum.all.should == TestEnum::OPTIONS.map {|o| TestEnum.build(o) }
  end
  
  it "should return an array of enums for a select tag" do
    TestEnum.all_with_name.should == TestEnum::OPTIONS.map {|o| [TestEnum.build(o).name, TestEnum.build(o).to_s] }
  end
  
  it "should return a type error when adding an invalid option" do
    TestEnum.build(:invalid_option).class.should == TypeError
  end
  
  context "with a collection of enums" do
    before(:each) do
      @one = TestEnum.build(:one)
      @two = TestEnum.build(:two)
      @three = TestEnum.build(:three)

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

  it "should work with include ClassyEnum" do
    IncludedEnum.build(:one).to_s.should == TestEnum.build(:one).to_s
  end
  
end

describe "A ClassyEnum instance" do
  before { @enum = TestEnum.build(:one) }
  
  it "should be a TestEnum" do
    @enum.should be_a(TestEnum)
  end

  it "should convert to a string" do
    @enum.to_s.should == "one"
  end
  
  it "should convert to a symbol" do
    @enum.to_sym.should == :one
  end

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
    @enum_string = TestEnum.build("one")
    
    @enum.should == @enum_string
  end
end

describe "An ClassyEnumValue" do
  before(:each) { @enum = TestEnum.build(:two) }
  
  it "should override the default instance methods" do
    @enum.test_instance_method?.should be_true
  end

  it "should override the default class methods" do
    TestEnumTwo.test_class_method?.should be_true
  end
end
