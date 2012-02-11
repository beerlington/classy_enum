require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class CatBreed < ClassyEnum::Base
  enum_classes :abyssian, :bengal, :birman, :persian
  owner :cat

  def breed_color
    "#{cat.color} #{name}"
  end
end

class Cat < ActiveRecord::Base
  classy_enum_attr :breed, :enum => :cat_breed
  attr_accessor :color
  delegate :breed_color, :to => :breed
end

class OtherCat < ActiveRecord::Base
  classy_enum_attr :breed, :enum => :cat_breed, :serialize_as_json => true
  attr_accessor :color
  delegate :breed_color, :to => :breed
end

describe Cat do
  let(:abyssian) { Cat.new(:breed => :abyssian, :color => 'black') }
  let(:persian) { OtherCat.new(:breed => :persian, :color => 'white') }

  it 'should delegate breed color to breed with an ownership reference' do
    abyssian.breed_color { should eql('black Abyssian') }
    persian.breed_color { should eql('white Persian') }
  end

  it 'should correctly serialize without the owner reference' do
    JSON.parse(abyssian.to_json)['cat']['breed'].should == 'abyssian'
  end

  it 'should convert the enum to a string when serializing' do
    JSON.parse(persian.to_json)['other_cat']['breed'].should be_a(Hash)
  end

end
