require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ClassyEnumCollection < ClassyEnum::Base
  delegate :odd?, :to => :to_i
end

class ClassyEnumCollection::One < ClassyEnumCollection
end

class ClassyEnumCollection::Two < ClassyEnumCollection
end

class ClassyEnumCollection::Three < ClassyEnumCollection
end

describe ClassyEnum::Collection do
  subject(:enum) { ClassyEnumCollection }

  its(:enum_options) { should == [ClassyEnumCollection::One, ClassyEnumCollection::Two, ClassyEnumCollection::Three] }
  its(:all) { should == [ClassyEnumCollection::One.new, ClassyEnumCollection::Two.new, ClassyEnumCollection::Three.new] }
  its(:select_options) { should == [['One', 'one'],['Two', 'two'], ['Three', 'three']] }

  context '.map' do
    it 'should behave like an enumerable' do
      enum.map(&:to_s).should == %w(one two three)
    end
  end

  context '#<=> (equality)' do
    its(:first) { should == ClassyEnumCollection::One.new }
    its(:first) { should == :one }
    its(:first) { should == 'one' }
    its(:first) { should_not == :two }
    its(:first) { should_not == :not_found }

    its(:max) { should == :three }
  end

  context '.find, .detect, []' do
    let(:expected_enum) { ClassyEnumCollection::Two.new }

    [:find, :detect, :[]].each do |method|
      it 'should return an instance when searching by symbol' do
        enum.send(method, :two).should == expected_enum
      end

      it 'should return an instance when searching by string' do
        enum.send(method, 'two').should == expected_enum
      end

      it 'should behave like an enumerable when using a block' do
        enum.send(method) {|e| e.to_s == 'two'}.should == expected_enum
      end

      it 'should return nil if item cannot be found' do
        enum.send(method, :not_found).should be_nil
      end
    end
  end

  context '.select' do
    let(:expected_enum) { ClassyEnumCollection::Two.new }

    it 'returns an array with each item where the block returns true' do
      enum.select(&:odd?).should == [ClassyEnumCollection::One.new, ClassyEnumCollection::Three.new]
    end
  end
end

describe ClassyEnum::Collection, Comparable do
  let(:one) { ClassyEnumCollection::One.new }
  let(:two) { ClassyEnumCollection::Two.new }
  let(:three) { ClassyEnumCollection::Three.new }

  subject { [one, three, two] }
  its(:sort) { should eql([one, two, three]) }
  its(:max) { should eql(three) }
  its(:min) { should eql(one) }
end
