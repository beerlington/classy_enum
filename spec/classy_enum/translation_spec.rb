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
    I18n.available_locales = ['en', 'es']
    I18n.backend.store_translations :en, classy_enum: {classy_enum_translation: {one: 'One!', two: 'Two!' } }
    I18n.backend.store_translations :es, classy_enum: {classy_enum_translation: {one: 'Uno', two: 'Dos' } }
  end

  context '#text' do
    subject { ClassyEnumTranslation::One.new }

    context 'default' do
      before { I18n.reload! }
      its(:text) { should == 'One' }
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

    context 'default' do
      before { I18n.reload! }
      its(:select_options) { should == [["One", "one"], ["Two", "two"]] }
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
