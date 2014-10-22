require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ClassyEnumBase < ClassyEnum::Base
end

class ClassyEnumBase::One < ClassyEnumBase
end

class ClassyEnumBase::Two < ClassyEnumBase
end

describe ClassyEnum::Base do
  context '.build' do
    context 'invalid option' do
      it 'should return the option' do
        ClassyEnumBase.build(:invalid_option).should == :invalid_option
      end
    end

    context 'string option' do
      subject { ClassyEnumBase.build("one") }
      it { should be_a(ClassyEnumBase::One) }
    end

    context 'symbol option' do
      subject { ClassyEnumBase.build(:two) }
      it { should be_a(ClassyEnumBase::Two) }
    end

    context 'nil' do
      subject { ClassyEnumBase.build(nil) }
      it { should eq(nil) }
    end

    context 'empty string' do
      subject { ClassyEnumBase.build('') }
      it { should eq('') }
    end
  end

  context '#new' do
    subject { ClassyEnumBase::One }
    its(:new) { should be_a(ClassyEnumBase::One) }
    its(:new) { should == ClassyEnumBase::One.new  }
  end

  context 'Subclass naming' do
    it 'should raise an error when invalid' do
      -> {
        class WrongSublcassName < ClassyEnumBase; end
      }.should raise_error(ClassyEnum::SubclassNameError)
    end
  end

  context '#base_class' do
    let(:base_class) { double }

    it 'returns class base_class' do
      enum = ClassyEnumBase.build(:two)
      enum.class.base_class = base_class
      enum.base_class.should == base_class
    end
  end
end
