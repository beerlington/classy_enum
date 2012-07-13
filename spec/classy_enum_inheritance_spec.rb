require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class ProjectTier < ClassyEnum::Base
  class_attribute :inherited_properties
end

class ProjectTierOne < ProjectTier
  self.inherited_properties = [1,2,3]
end

class ProjectTierTwo < ProjectTierOne
  self.inherited_properties += [4,5,6]
end

describe 'Classy Enum inheritance' do
  it 'should inherit from the previous class' do
    ProjectTierOne.inherited_properties.should == [1,2,3]
    ProjectTierTwo.inherited_properties.should == [1,2,3,4,5,6]
  end

  it 'should instantiate the subclass' do
    ProjectTierTwo.build(:two).should == ProjectTierTwo.new
  end

  it 'should have the right index' do
    ProjectTierTwo.new.index.should == 2
  end
end
