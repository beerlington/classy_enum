require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Normalize < ClassyEnum::Base; end
class Normalize::One < Normalize; end

describe ClassyEnum do
  context '._normalize_value' do
    it 'converts an enum to a string' do
      value = ClassyEnum._normalize_value(Normalize::One)
      value.should == 'one'
    end

    it 'converts a symbol to a string' do
      value = ClassyEnum._normalize_value(:one)
      value.should == 'one'
    end

    it 'leaves a string as a string' do
      value = ClassyEnum._normalize_value('one')
      value.should == 'one'
    end

    it 'does not convert nil' do
      value = ClassyEnum._normalize_value(nil)
      value.should be_nil
    end

    it 'does not convert an empty string if allowed' do
      value = ClassyEnum._normalize_value('', nil, true)
      value.should eql('')
    end

    it 'uses the default value if blank and does not allow blank' do
      value = ClassyEnum._normalize_value(nil, 'one')
      value.should eql('one')
    end
  end

  context '._normalize_default' do
    let(:enum) { Normalize }

    it 'returns a string when provided' do
      default = ClassyEnum._normalize_default('one', enum)
      default.should eql('one')
    end

    it 'allows a proc' do
      value = ->(enum) { enum.max }
      default = ClassyEnum._normalize_default(value, enum)
      default.should == enum.max
    end

    it 'raises an exception if not an enum value' do
      expect { ClassyEnum._normalize_default('two', enum) }.to raise_error(ClassyEnum::InvalidDefault)
    end

    it 'returns nil if nil is provided' do
      ClassyEnum._normalize_default(nil, enum).should be_nil
    end

    it 'returns empty string if provided' do
      ClassyEnum._normalize_default('', enum).should eql('')
    end
  end
end
