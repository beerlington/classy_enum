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

  it "should return a type error when adding an invalid option" do
    TestEnum.build(:invalid_option).class.should == TypeError
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
  its(:test_instance_method?) { should be_false }
end

describe "A ClassyEnum that overrides values" do
  subject { TestEnum.build(:two) }

  its(:test_instance_method?) { should be_true }

  it "should override the default class methods" do
    TestEnumTwo.test_class_method?.should be_true
  end
end

describe 'A ClassEnum subclass that is improperly named' do
  it 'should raise an error' do
    lambda {
      class WrongSublcassName < TestEnum; end
    }.should raise_error(ClassyEnum::SubclassNameError)
  end
end
