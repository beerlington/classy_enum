require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ClassyEnumCollection < ClassyEnum::Base
end

class ClassyEnumCollectionOne < ClassyEnumCollection
end

class ClassyEnumCollectionTwo < ClassyEnumCollection
end

describe ClassyEnum::Collection do
  subject { ClassyEnumCollection }

  its(:enum_options) { should == [ClassyEnumCollectionOne, ClassyEnumCollectionTwo] }
  its(:all) { should == [ClassyEnumCollectionOne.new, ClassyEnumCollectionTwo.new] }
  its(:select_options) { should == [['One', 'one'],['Two', 'two']] }
end
