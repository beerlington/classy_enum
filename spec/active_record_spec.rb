require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class ActiveDog < ActiveRecord::Base
  classy_enum_attr :breed

  validates :name,
    :presence => true,
    :uniqueness => { :scope => [:breed] }

end

describe ActiveDog do
  before do
    ActiveDog.create!(:name => 'Sebastian', :breed => :golden_retriever)
    ActiveDog.create!(:name => 'Sirius', :breed => :husky)
  end

  it 'should allow validation with classy enum scope' do
    dog = ActiveDog.new(:name => 'Sirius', :breed => :golden_retriever)
    dog.should be_valid
  end
end
