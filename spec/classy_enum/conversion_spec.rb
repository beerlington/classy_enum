require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ClassyEnumConversion < ClassyEnum::Base
end

class ClassyEnumConversionOne < ClassyEnumConversion
end

class ClassyEnumConversionTwo < ClassyEnumConversion
end

describe ClassyEnum::Conversion do
  context '#to_i' do
    specify { ClassyEnumConversionOne.new.to_i.should == 1 }
    specify { ClassyEnumConversionTwo.new.to_i.should == 2 }
  end

  context '#index' do
    specify { ClassyEnumConversionOne.new.index.should == 1 }
    specify { ClassyEnumConversionTwo.new.index.should == 2 }
  end

  context '#to_s' do
    specify { ClassyEnumConversionOne.new.to_s.should == 'one' }
    specify { ClassyEnumConversionTwo.new.to_s.should == 'two' }
  end

  context '#to_sym' do
    specify { ClassyEnumConversionOne.new.to_sym.should == :one }
    specify { ClassyEnumConversionTwo.new.to_sym.should == :two }
  end

  context '#as_json' do
    context 'serialize_as_json is false' do
      specify { ClassyEnumConversionOne.new.as_json.should == 'one' }
      specify { ClassyEnumConversionTwo.new.as_json.should == 'two' }
    end

    context 'serialize_as_json is true' do
      specify do
        enum = ClassyEnumConversionOne.new
        enum.serialize_as_json = true
        enum.instance_variable_set('@key', 'value')
        enum.as_json.should == {'key' => 'value' }
      end

      specify do
        enum = ClassyEnumConversionOne.new
        enum.serialize_as_json = true
        enum.instance_variable_set('@key', 'value')
        enum.as_json.should == {'key' => 'value' }
      end
    end
  end
end
