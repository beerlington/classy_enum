require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ClassyEnumTranslation < ClassyEnum::Base
end

class ClassyEnumTranslation::One < ClassyEnumTranslation
end

class ClassyEnumTranslation::Two < ClassyEnumTranslation
end

describe ClassyEnum::Translation do

  before do
    I18n.reload!
    I18n.backend.store_translations :en, :classy_enum => {:classy_enum_translation => {:one => 'One!', :two => 'Two!' } }
    I18n.backend.store_translations :es, :classy_enum => {:classy_enum_translation => {:one => 'Uno', :two => 'Dos' } }
  end

  context '#text' do
    subject { ClassyEnumTranslation::One.new }

    # Rails 4.2 enforces available locales and this will always fail
    unless I18n.enforce_available_locales
      context 'default' do
        its(:text) { should == 'One' }
      end
    end

    context 'en' do
      before { I18n.locale = :en }
      its(:text) { should == 'One!' }
    end

    context 'es' do
      before { I18n.locale = :es }
      its(:text) { should == 'Uno' }
    end
  end

  context '.select_options' do
    subject { ClassyEnumTranslation }

    # Rails 4.2 enforces available locales and this will always fail
    unless I18n.enforce_available_locales
      context 'default' do
        before { I18n.reload! }
        its(:select_options) { should == [["One", "one"], ["Two", "two"]] }
      end
    end

    context 'en' do
      before { I18n.locale = :en }
      its(:select_options) { should == [["One!", "one"], ["Two!", "two"]] }
    end

    context 'es' do
      before { I18n.locale = :es }
      its(:select_options) { should == [["Uno", "one"], ["Dos", "two"]] }
    end
  end
end
