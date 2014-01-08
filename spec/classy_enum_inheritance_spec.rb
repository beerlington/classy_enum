require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class ProjectTier < ClassyEnum::Base
  def self.hello
    'world'
  end
end

class ProjectTier::One < ProjectTier
end

class ProjectTier::Two < ProjectTier::One
end

describe 'Classy Enum inheritance' do
  it 'should inherit from the previous class' do
    ProjectTier::Two.hello.should eq(ProjectTier::One.hello)
  end

  it 'should instantiate the subclass' do
    ProjectTier.build(:two).should == ProjectTier::Two.new
  end

  it 'should have the right index' do
    ProjectTier::Two.new.index.should == 2
  end
end
