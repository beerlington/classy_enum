require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ClassyEnumTranslation < ClassyEnum::Base
end

class ClassyEnumTranslation::One < ClassyEnumTranslation
end

class ClassyEnumTranslation::Two < ClassyEnumTranslation
end

class ClassyEnumTranslation::Three < ClassyEnumTranslation
end

describe ClassyEnum::Translation do
  subject { ClassyEnumTranslation::One.new }

  before { I18n.reload! }

  context '#text' do
    context 'default' do
      its(:text) { should == 'One' }
    end

    context 'en' do
      before do
        I18n.locale = :en
        I18n.backend.store_translations :en, :classy_enum => {:classy_enum_translation => {:one => 'One!' } }
      end

      its(:text) { should == 'One!' }
    end

    context 'es' do
      before do
        I18n.locale = :es
        I18n.backend.store_translations :es, :classy_enum => {:classy_enum_translation => {:one => 'Uno' } }
      end

      its(:text) { should == 'Uno' }
    end
  end
end
