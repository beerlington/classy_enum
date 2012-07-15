require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "A Dog" do

  context "with valid breed options" do
    subject { Dog.new(:breed => :golden_retriever) }

    it { should be_valid }
    its(:breed) { should be_a(Breed::GoldenRetriever) }
    its(:breed_options) { should == {:enum => Breed, :allow_blank => false} }
  end

  it "should not be valid with a nil breed" do
    Dog.new(:breed => nil).should_not be_valid
  end

  it "should not be valid with a blank breed" do
    Dog.new(:breed => "").should_not be_valid
  end

  context "with invalid breed options" do
    let(:dog) { Dog.new(:breed => :fake_breed) }
    subject { dog }
    it { should_not be_valid }

    it 'should have an error message containing the right options' do
      dog.valid?
      dog.errors[:breed].should include(Breed.invalid_message)
    end
  end

end

describe "A ClassyEnum that allows blanks" do

  context "with valid breed options" do
    subject { AllowBlankBreedDog.new(:breed => :golden_retriever) }

    it { should be_valid }
    its(:breed_options) { should == {:enum => Breed, :allow_blank => true} }
  end

  it "should be valid with a nil breed" do
    AllowBlankBreedDog.new(:breed => nil).should be_valid
  end

  it "should be valid with a blank breed" do
    AllowBlankBreedDog.new(:breed => "").should be_valid
  end

  context "with invalid breed options" do
    let(:dog) { AllowBlankBreedDog.new(:breed => :fake_breed) }
    subject { dog }
    it { should_not be_valid }

    it 'should have an error message containing the right options' do
      dog.valid?
      dog.errors[:breed].should include(Breed.invalid_message)
    end
  end

end

describe "A ClassyEnum that allows nils" do

  context "with valid breed options" do
    subject { AllowNilBreedDog.new(:breed => :golden_retriever) }

    it { should be_valid }
    its(:breed_options) { should == {:enum => Breed, :allow_blank => false} }
  end

  it "should be valid with a nil breed" do
    AllowNilBreedDog.new(:breed => nil).should be_valid
  end

  it "should not be valid with a blank breed" do
    AllowNilBreedDog.new(:breed => "").should_not be_valid
  end

  context "with invalid breed options" do
    let(:dog) { AllowNilBreedDog.new(:breed => :fake_breed) }
    subject { dog }
    it { should_not be_valid }

    it 'should have an error message containing the right options' do
      dog.valid?
      dog.errors[:breed].should include(Breed.invalid_message)
    end
  end

end

describe "A ClassyEnum that has a different field name than the enum" do
  subject { OtherDog.new(:other_breed => :snoop) }
  its(:other_breed) { should be_a(Breed::Snoop) }
end
