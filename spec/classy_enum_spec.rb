require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class TestEnum < ClassyEnum::Base
  def self.test_class_method?
    false
  end

  def test_instance_method?
    false
  end
end

class TestEnumOne < TestEnum
end

class TestEnumTwo < TestEnum
  def self.test_class_method?
    true
  end

  def test_instance_method?
    true
  end
end

class TestEnumThree < TestEnum
end

describe "A ClassyEnum Descendent" do

  it "should return an array of enums" do
    TestEnum.all.map(&:class).should == [TestEnumOne, TestEnumTwo, TestEnumThree]
  end

  it "should return an array of enums for a select tag" do
    TestEnum.select_options.should == TestEnum.enum_options.map {|o| [TestEnum.build(o).name, TestEnum.build(o).to_s] }
  end

  it "should return a type error when adding an invalid option" do
    TestEnum.build(:invalid_option).class.should == TypeError
  end

  it "should find an enum by symbol" do
    TestEnum.find(:one).class.should == TestEnumOne
  end

  it "should find an enum by string" do
    TestEnum.find("one").class.should == TestEnumOne
  end

  it "should create an instance with a string" do
    TestEnum.build("one").should be_a(TestEnumOne)
  end
end

describe "A collection of ClassyEnums" do
  let(:one) { TestEnum.build(:one) }
  let(:two) { TestEnum.build(:two) }
  let(:three) { TestEnum.build(:three) }

  subject { [one, three, two] }
  its(:sort) { should eql([one, two, three]) }
  its(:max) { should eql(three) }
end

describe "A ClassyEnum element" do
  subject { TestEnumOne }

  its(:new) { should be_a(TestEnumOne) }
  its(:new) { should == TestEnumOne.new  }
  it { should_not be_a_test_class_method }
end

describe "A ClassyEnum instance" do
  subject { TestEnum.build(:one) }

  it { should be_a(TestEnum) }
  its(:class) { should eql(TestEnumOne) }
  its(:one?) { should be_true }
  its(:two?) { should be_false }
  its(:index) { should eql(1) }
  its(:to_i) { should eql(1) }
  its(:to_s) { should eql('one') }
  its(:to_sym) { should be(:one) }
  its(:name) { should eql('One') }
  its(:test_instance_method?) { should be_false }
end

describe "A ClassyEnum that overrides values" do
  subject { TestEnum.build(:two) }

  its(:test_instance_method?) { should be_true }

  it "should override the default class methods" do
    TestEnumTwo.test_class_method?.should be_true
  end
end
