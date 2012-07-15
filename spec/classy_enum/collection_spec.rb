require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ClassyEnumCollection < ClassyEnum::Base
end

class ClassyEnumCollectionOne < ClassyEnumCollection
end

class ClassyEnumCollectionTwo < ClassyEnumCollection
end

class ClassyEnumCollectionThree < ClassyEnumCollection
end

describe ClassyEnum::Collection do
  subject { ClassyEnumCollection }

  its(:enum_options) { should == [ClassyEnumCollectionOne, ClassyEnumCollectionTwo, ClassyEnumCollectionThree] }
  its(:all) { should == [ClassyEnumCollectionOne.new, ClassyEnumCollectionTwo.new, ClassyEnumCollectionThree.new] }
  its(:select_options) { should == [['One', 'one'],['Two', 'two'], ['Three', 'three']] }
end

describe ClassyEnum::Collection, Comparable do
  let(:one) { ClassyEnumCollectionOne.new }
  let(:two) { ClassyEnumCollectionTwo.new }
  let(:three) { ClassyEnumCollectionThree.new }

  subject { [one, three, two] }
  its(:sort) { should eql([one, two, three]) }
  its(:max) { should eql(three) }
  its(:min) { should eql(one) }
end
