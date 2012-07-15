require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ClassyEnumCollection < ClassyEnum::Base
end

class ClassyEnumCollection::One < ClassyEnumCollection
end

class ClassyEnumCollection::Two < ClassyEnumCollection
end

class ClassyEnumCollection::Three < ClassyEnumCollection
end

describe ClassyEnum::Collection do
  subject { ClassyEnumCollection }

  its(:enum_options) { should == [ClassyEnumCollection::One, ClassyEnumCollection::Two, ClassyEnumCollection::Three] }
  its(:all) { should == [ClassyEnumCollection::One.new, ClassyEnumCollection::Two.new, ClassyEnumCollection::Three.new] }
  its(:select_options) { should == [['One', 'one'],['Two', 'two'], ['Three', 'three']] }
end

describe ClassyEnum::Collection, Comparable do
  let(:one) { ClassyEnumCollection::One.new }
  let(:two) { ClassyEnumCollection::Two.new }
  let(:three) { ClassyEnumCollection::Three.new }

  subject { [one, three, two] }
  its(:sort) { should eql([one, two, three]) }
  its(:max) { should eql(three) }
  its(:min) { should eql(one) }
end
