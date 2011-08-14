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

describe Cat do
  subject { Cat.new(:breed => :abyssian, :color => 'black') }
  its(:breed_color) { should eql('black Abyssian') }
end
