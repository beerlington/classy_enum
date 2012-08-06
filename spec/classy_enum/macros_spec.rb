require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'classy_enum/macros'

describe 'ClassyEnum macros: #enum and #enums' do
  before :all do
    enum :number, :no_context do
      enum :one do
        def send_email?
          true
        end
      end

      enums :two, :three
    end
  end

  context '.build' do
    context 'invalid option' do
      it 'should return the option' do
        Number.build(:invalid_option).should == :invalid_option
      end
    end

    context 'string option' do
      subject { Number.build("one") }
      it { should be_a(::Number::One) }
    end

    context 'symbol option' do
      describe 'two' do
        subject { Number.build(:two) }
        it { should be_a(::Number::Two) }
      end

      describe 'three' do
        subject { Number.build(:three) }
        it { should be_a(::Number::Three) }
      end
    end
  end
end

describe 'ClassyEnum macros: #enum and #enums' do
  before :all do
    enum_for :color, [:red, :blue], parent: :no_context
  end

  context '.build' do
    context 'invalid option' do
      it 'should return the option' do
        Color.build(:invalid_option).should == :invalid_option
      end
    end

    context 'string option' do
      subject { Color.build("red") }
      it { should be_a(::Color::Red) }
    end

    context 'symbol option' do
      describe 'two' do
        subject { Color.build(:blue) }
        it { should be_a(::Color::Blue) }
      end
    end
  end
end  