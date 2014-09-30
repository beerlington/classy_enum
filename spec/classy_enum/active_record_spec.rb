require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

ActiveRecord::Schema.define(:version => 1) do
  create_table :dogs, :force => true do |t|
    t.string :breed
    t.string :other_breed
    t.string :color
    t.string :name
    t.integer :age
  end

  create_table :cats, :force => true do |t|
    t.string :breed
    t.string :other_breed
    t.string :another_breed
  end
end

class Breed < ClassyEnum::Base; end
class Breed::GoldenRetriever < Breed; end
class Breed::Snoop < Breed; end
class Breed::Husky < Breed; end

class Color < ClassyEnum::Base; end
class Color::White < Color; end;
class Color::Black < Color; end;

class CatBreed < ClassyEnum::Base
  owner :cat

  def breed_color
    "#{cat.color} #{self}"
  end
end

class CatBreed::Abyssian < CatBreed; end
class CatBreed::Bengal < CatBreed; end
class CatBreed::Birman < CatBreed; end
class CatBreed::Persian < CatBreed; end

class Dog < ActiveRecord::Base; end

class DefaultDog < Dog
  classy_enum_attr :breed
end

class AllowBlankBreedDog < Dog
  classy_enum_attr :breed, :allow_blank => true
end

class AllowNilBreedDog < Dog
  classy_enum_attr :breed, :allow_nil => true
end

class OtherDog < Dog
  classy_enum_attr :other_breed, :class_name => 'Breed'
end

describe DefaultDog do
  specify { DefaultDog.new(:breed => nil).should_not be_valid }
  specify { DefaultDog.new(:breed => '').should_not be_valid }

  [:golden_retriever, 'golden_retriever', Breed::GoldenRetriever.new, Breed::GoldenRetriever].each do |option|
    context "with a valid breed option" do
      subject { DefaultDog.new(:breed => option) }
      it { should be_valid }
      its(:breed) { should be_a(Breed::GoldenRetriever) }
      its('breed.allow_blank') { should be_false }

      it 'stores the enum as a valid string representation' do
        subject.save!
        subject.reload
        subject.breed.should be_a(Breed::GoldenRetriever)
      end
    end
  end

  context "with invalid breed options" do
    subject { DefaultDog.new(:breed => :fake_breed) }
    it { should_not be_valid }
    it 'has an error on :breed' do
      subject.valid?
      subject.errors[:breed].size.should eql(1)
    end
  end
end

describe "A ClassyEnum that allows blanks" do
  specify { AllowBlankBreedDog.new(:breed => nil).should be_valid }
  specify { AllowBlankBreedDog.new(:breed => '').should be_valid }

  context "with valid breed options" do
    subject { AllowBlankBreedDog.new(:breed => :golden_retriever) }
    it { should be_valid }
    its('breed.allow_blank') { should be_true }
  end

  context "with invalid breed options" do
    subject { AllowBlankBreedDog.new(:breed => :fake_breed) }
    it { should_not be_valid }
    it 'has an error on :breed' do
      subject.valid?
      subject.errors[:breed].size.should eql(1)
    end
  end
end

describe "A ClassyEnum that allows nils" do
  specify { AllowNilBreedDog.new(:breed => nil).should be_valid }
  specify { AllowNilBreedDog.new(:breed => '').should_not be_valid }

  context "with valid breed options" do
    subject { AllowNilBreedDog.new(:breed => :golden_retriever) }
    it { should be_valid }
    its('breed.allow_blank') { should be_true }

    it 'should return nil when set to nil' do
      bd = AllowNilBreedDog.new(:breed => nil)
      expect(bd.breed).to eql(nil)
      if bd.breed
        fail 'Expected breed to be falsy'
      end
    end
  end

  context "with invalid breed options" do
    subject { AllowNilBreedDog.new(:breed => :fake_breed) }
    it { should_not be_valid }
    it 'has an error on :breed' do
      subject.valid?
      subject.errors[:breed].size.should eql(1)
    end
  end
end

describe "A ClassyEnum that has a different field name than the enum" do
  subject { OtherDog.new(:other_breed => :snoop) }
  its(:other_breed) { should be_a(Breed::Snoop) }
end

class ActiveDog < Dog
  classy_enum_attr :color
  validates_uniqueness_of :name, :scope => :color
  scope :goldens, lambda { where(:breed => Breed.build('golden_retriever')) }
end

describe ActiveDog do
  context 'uniqueness on name' do
    subject { ActiveDog.new(:name => 'Kitteh', :breed => :golden_retriever, :color => :black) }
    it { should be_valid }

    context 'with existing kitteh' do
      before do
        ActiveDog.create!(:name => 'Kitteh', :breed => :husky, :color => :black)
      end

      it 'has an error on :name' do
        subject.valid?
        subject.errors[:name].size.should eql(1)
      end
    end
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

    it 'should have a working scope with count' do
      ActiveDog.goldens.size.should == 1
    end
  end

end

class DefaultValueDog < Dog
  classy_enum_attr :breed, :default => :snoop
end

describe DefaultValueDog do
  its(:breed) { should == :snoop }
end

class DynamicDefaultValueDog < Dog
  classy_enum_attr :breed, :default => lambda { |enum| enum.max }
end

describe DynamicDefaultValueDog do
  its(:breed) { should == :husky }
end

describe Dog, 'with invalid default value' do
  it 'raises error with invalid default' do
    expect {
      Class.new(Dog) { classy_enum_attr :breed, :default => :nope }
    }.to raise_error(ClassyEnum::InvalidDefault)
  end
end

class Cat < ActiveRecord::Base
end

class DefaultCat < Cat
  classy_enum_attr :breed, :enum => 'CatBreed'
  classy_enum_attr :other_breed, :enum => 'CatBreed', :default => 'persian'
  attr_accessor :color
  delegate :breed_color, :to => :breed
end

class OtherCat < Cat
  classy_enum_attr :breed, :enum => 'CatBreed', :serialize_as_json => true
  classy_enum_attr :other_breed, :enum => 'CatBreed', :default => 'persian', :allow_nil => true
  classy_enum_attr :another_breed, :enum => 'CatBreed', :default => 'persian', :allow_blank => true
  attr_accessor :color
  delegate :breed_color, :to => :breed
end

describe DefaultCat do
  let(:abyssian) { DefaultCat.new(:breed => :abyssian, :color => 'black') }
  let(:persian) { OtherCat.new(:breed => :persian, :color => 'white') }

  it 'should delegate breed color to breed with an ownership reference' do
    abyssian.breed_color { should eql('black Abyssian') }
    persian.breed_color { should eql('white Persian') }
  end

  it 'persists the default, when set to nil' do
    cat = DefaultCat.create(:breed => :abyssian)
    expect(DefaultCat.where(:other_breed => 'persian')).to include(cat)
  end

  it 'uses the default if explictly set to nil and does not allow nil' do
    abyssian.update_attributes!(:other_breed => nil)
    DefaultCat.where(:other_breed => 'persian').should include(abyssian)
    DefaultCat.last.other_breed.should == 'persian'
  end

  it 'uses the default if explictly set to blank and does not allow blank' do
    abyssian.update_attributes!(:other_breed => '')
    DefaultCat.where(:other_breed => 'persian').should include(abyssian)
    DefaultCat.last.other_breed.should == 'persian'
  end

  it 'allows nil even with a default' do
    persian.update_attributes!(:other_breed => nil)
    OtherCat.where(:other_breed => nil).count.should eql(1)
    OtherCat.last.other_breed.should be_nil
  end

  it 'allows blank even with a default' do
    persian.update_attributes!(:another_breed => '')
    OtherCat.where(:another_breed => '').count.should eql(1)
    OtherCat.last.another_breed.should be_blank
    OtherCat.last.another_breed.should_not be_nil
  end
end
