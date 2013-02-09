require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class ProjectTier < ClassyEnum::Base
  class_attribute :inherited_properties
end

class ProjectTier::One < ProjectTier
  self.inherited_properties = [1,2,3]
end

class ProjectTier::Two < ProjectTier::One
  self.inherited_properties += [4,5,6]
end

describe 'Classy Enum inheritance' do
  it 'should inherit from the previous class' do
    ProjectTier::One.inherited_properties.should eql([1,2,3])
    ProjectTier::Two.inherited_properties.should eql([1,2,3,4,5,6])
  end

  it 'should instantiate the subclass' do
    ProjectTier::Two.build(:two).should == ProjectTier::Two.new
  end

  it 'should have the right index' do
    ProjectTier::Two.new.index.should == 2
  end
end
