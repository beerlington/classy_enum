require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'using enum_select input' do
  include FormtasticSpecHelper

  Formtastic::SemanticFormHelper.builder = ClassyEnum::SemanticFormBuilder

  # Reset output buffer
  before { @output_buffer = "" }

  context 'when building a form with a classy_enum select' do
    context 'with an object that has the enum set' do
      let(:output) do
        semantic_form_for(Dog.new(:breed => :snoop), :url => "/") do |builder|
          concat(builder.input(:breed, :as => :enum_select))
        end
      end

      it 'should produce an unselected option tag for Golden Retriever' do
        output.should =~ Regexp.new(%q{option value="golden_retriever">Golden Retriever})
      end

      it 'should produce a selected option tag for Snoop' do
        output.should =~ Regexp.new(%q{<option value="snoop" selected="selected">Snoop})
      end

      it 'should not produce a blank option tag' do
        output.should_not =~ Regexp.new(%q{<option value=""><})
      end
    end

    context 'with an object that has a nil enum' do
      let(:output) do
        semantic_form_for(Dog.new, :url => "/") do |builder|
          concat(builder.input(:breed, :as => :enum_select))
        end
      end

      it 'should produce an unselected option tag for Golden Retriever' do
        output.should =~ Regexp.new(%q{<option value="golden_retriever">Golden Retriever})
      end

      it 'should not produce an selected option tag' do
        output.should_not =~ Regexp.new("selected")
      end
    end

    context 'with an object that allows blank enums' do
      let(:output) do
        semantic_form_for(AllowBlankBreedDog.new, :url => "/") do |builder|
          concat(builder.input(:breed, :as => :enum_select))
        end
      end

      it 'should produce an unselected option tag for Golden Retriever' do
        output.should =~ Regexp.new(%q{<option value="golden_retriever">Golden Retriever})
      end

      it 'should produce a blank option tag' do
        output.should =~ Regexp.new(%q{<option value=""><})
      end
    end

    context 'with an object that allows nil enums' do
      let(:output) do
        semantic_form_for(AllowNilBreedDog.new, :url => "/") do |builder|
          concat(builder.input(:breed, :as => :enum_select))
        end
      end

      it 'should produce an unselected option tag for Golden Retriever' do
        output.should =~ Regexp.new(%q{<option value="golden_retriever">Golden Retriever})
      end

      it 'should produce a blank option tag' do
        output.should_not =~ Regexp.new(%q{<option value=""><})
      end
    end

  end

  it 'should raise an error if the attribute is not a ClassyEnum object' do
    lambda do
      semantic_form_for(Dog.new(:breed => :snoop), :url => "/") do |builder|
        concat(builder.input(:id, :as => :enum_select))
      end
    end.should raise_error("id is not a ClassyEnum object. Make sure you've added 'classy_enum_attr :id' to your model")
  end

  it 'should raise an error if the attribute is not a ClassyEnum object and its value is nil' do
    lambda do
      semantic_form_for(Dog.new, :url => "/") do |builder|
        concat(builder.input(:id, :as => :enum_select))
      end
    end.should raise_error("id is not a ClassyEnum object. Make sure you've added 'classy_enum_attr :id' to your model")
  end

end

