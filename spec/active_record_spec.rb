require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class ActiveDog < ActiveRecord::Base
  classy_enum_attr :breed, :suffix => 'type'

  validates :name,
    :presence => true,
    :uniqueness => { :scope => [:breed] }

  scope :goldens, where(:breed => 'golden_retriever')

end

describe ActiveDog do

  context 'valid instance' do
    subject { ActiveDog.new(:name => 'sirius', :breed => :golden_retriever) }

    it { should have(:no).errors_on(:breed) }
    its(:breed_type) { should be_a_golden_retriever }
    its(:breed) { should == 'golden_retriever' }
  end

  context 'invalid instance' do
    subject { ActiveDog.new(:name => 'sirius', :breed => :golden_retrievers) }

    it { should have(1).error_on(:breed) }
  end

  context 'scopes' do
    let!(:golden) { ActiveDog.create!(:name => 'Sebastian', :breed => :golden_retriever) }
    let!(:husky) { ActiveDog.create!(:name => 'Sirius', :breed => :husky) }

    after { ActiveDog.destroy_all }

    it 'should know all dogs' do
      ActiveDog.all.should include(golden, husky)
    end

    it 'should have a working scope' do
      ActiveDog.goldens.should include(golden)
      ActiveDog.goldens.should_not include(husky)
    end
  end

end
