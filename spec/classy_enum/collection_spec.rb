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
      enum.select {|e| e < :three }.should include(:one, :two)
    end
  end

  context '.last' do
    its(:last) { should == ClassyEnumCollection::Three.new }
    its(:last) { should == :three }
    its(:last) { should_not == :one }
  end

  context '#<=> (equality)' do
    its(:first) { should == ClassyEnumCollection::One.new }
    its(:first) { should == ClassyEnumCollection::One }
    its(:first) { should == :one }
    its(:first) { should == 'one' }
    its(:first) { should_not == :two }
    its(:first) { should_not == :not_found }
    its(:first) { should_not == String }

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

  context '#enum_options' do
    let(:options) { double }

    before do
      subject.enum_options = options
    end

    it 'returns class enum_options' do
      subject.new.enum_options.should == options
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
