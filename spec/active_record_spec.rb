require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Color < ClassyEnum::Base
end

class Color::White < Color; end;

class Color::Black < Color; end;

class ActiveDog < ActiveRecord::Base
  classy_enum_attr :breed, :suffix => 'type'
  classy_enum_attr :color

  validates :name,
    :presence => true,
    :uniqueness => { :scope => [:breed] }

  validates_uniqueness_of :name, :scope => :color

  scope :goldens, where(:breed => 'golden_retriever')

end

describe ActiveDog do

  context 'valid instance' do
    subject { ActiveDog.new(:name => 'sirius', :breed => :golden_retriever, :color => :black) }

    it { should have(:no).errors_on(:breed) }
    its(:breed_type) { should be_a_golden_retriever }
    its(:breed) { should == 'golden_retriever' }
  end

  context 'uniqueness on name' do
    subject { ActiveDog.new(:name => 'Kitteh', :breed => :golden_retriever, :color => :black) }
    it { should be_valid }

    context 'with existing kitteh' do
      before do
        ActiveDog.create!(:name => 'Kitteh', :breed => :husky, :color => :black)
      end

      it { should have(1).error_on(:name) }
    end
  end

  context 'invalid instance' do
    subject { ActiveDog.new(:name => 'sirius', :breed => :golden_retrievers, :color => :white) }

    it { should have(1).error_on(:breed) }
  end

  context 'scopes' do
    let!(:golden) { ActiveDog.create!(:name => 'Sebastian', :breed => :golden_retriever, :color => :white) }
    let!(:husky) { ActiveDog.create!(:name => 'Sirius', :breed => :husky, :color => :black) }

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
