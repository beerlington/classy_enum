require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class CatBreed < ClassyEnum::Base
  owner :cat

  def breed_color
    "#{cat.color} #{self}"
  end
end

class CatBreed::Abyssian < CatBreed
end

class CatBreed::Bengal < CatBreed
end

class CatBreed::Birman < CatBreed
end

class CatBreed::Persian < CatBreed
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
end
