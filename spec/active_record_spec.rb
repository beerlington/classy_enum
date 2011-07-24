require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class ActiveDog < ActiveRecord::Base
  classy_enum_attr :breed

  validates :name,
    :presence => true,
    :uniqueness => { :scope => [:breed] }

  scope :goldens, where(:breed => 'golden_retriever')

end

describe ActiveDog do
  before do
    ActiveDog.destroy_all
    @golden = ActiveDog.create!(:name => 'Sebastian', :breed => :golden_retriever) 
    @husky = ActiveDog.create!(:name => 'Sirius', :breed => :husky)
  end

  it 'should allow validation with classy enum scope' do
    dog = ActiveDog.new(:name => 'Sirius', :breed => :golden_retriever)
    dog.should be_valid
    dog.breed.golden_retriever?.should be_true
  end

  it 'should know all dogs' do
    ActiveDog.all.should include(@golden, @husky)
  end

  it 'should have a working scope' do
    ActiveDog.goldens.should include(@golden)
    ActiveDog.goldens.should_not include(@husky)
  end
end
