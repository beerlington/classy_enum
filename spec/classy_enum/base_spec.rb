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
      subject { ClassyEnumBase.build(:invalid_option) }
      its(:class) { should == TypeError }
    end

    context 'string option' do
      subject { ClassyEnumBase.build("one") }
      it { should be_a(ClassyEnumBase::One) }
    end

    context 'symbol option' do
      subject { ClassyEnumBase.build(:two) }
      it { should be_a(ClassyEnumBase::Two) }
    end
  end

  context '.invalid_message' do
    ClassyEnumBase.invalid_message.should == 'must be one or two'
  end

  context '#new' do
    subject { ClassyEnumBase::One }
    its(:new) { should be_a(ClassyEnumBase::One) }
    its(:new) { should == ClassyEnumBase::One.new  }
  end

  context 'Subclass naming' do
    it 'should raise an error when invalid' do
      lambda {
        class WrongSublcassName < ClassyEnumBase; end
      }.should raise_error(ClassyEnum::SubclassNameError)
    end
  end
end

describe ClassyEnum::Base, 'Arel visitor' do
  specify do
    Arel::Visitors::ToSql.instance_methods.map(&:to_sym).should include(:'visit_ClassyEnumBase_One', :'visit_ClassyEnumBase_Two')
  end
end
