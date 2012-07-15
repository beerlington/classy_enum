require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class TestEnum < ClassyEnum::Base
end

class TestEnumOne < TestEnum
end

class TestEnumTwo < TestEnum
end

describe ClassyEnum::Base do
  context '.build' do
    context 'invalid option' do
      subject { TestEnum.build(:invalid_option) }
      its(:class) { should == TypeError }
    end

    context 'string option' do
      subject { TestEnum.build("one") }
      it { should be_a(TestEnumOne) }
    end

    context 'symbol option' do
      subject { TestEnum.build(:two) }
      it { should be_a(TestEnumTwo) }
    end
  end

  context '.invalid_message' do
    TestEnum.invalid_message.should == 'must be one of one, two'
  end

  context '#new' do
    subject { TestEnumOne }
    its(:new) { should be_a(TestEnumOne) }
    its(:new) { should == TestEnumOne.new  }
  end

  context 'Subclass naming' do
    it 'should raise an error when invalid' do
      lambda {
        class WrongSublcassName < TestEnum; end
      }.should raise_error(ClassyEnum::SubclassNameError)
    end
  end
end

describe ClassyEnum::Base, 'Arel visitor' do
  specify do
    Arel::Visitors::ToSql.instance_methods.should include(:visit_TestEnumOne, :visit_TestEnumTwo)
  end
end
