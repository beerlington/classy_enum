require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'classy_enum/macros'

enum :priority do
  enum :one do
    def send_email?
      true
    end
  end 

  enums :two, :three
end

describe ClassyEnum::Base do
  context '.build' do
    context 'invalid option' do
      it 'should return the option' do
        Priority.build(:invalid_option).should == :invalid_option
      end
    end

    context 'string option' do
      subject { Priority.build("one") }
      it { should be_a(::Priority::One) }
    end

    context 'symbol option' do
      describe 'two' do
        subject { Priority.build(:two) }
        it { should be_a(::Priority::Two) }
      end

      describe 'three' do
        subject { Priority.build(:three) }
        it { should be_a(::Priority::Three) }
      end
    end
  end
end