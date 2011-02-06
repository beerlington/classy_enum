require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'using enum_select input' do
  include FormtasticSpecHelper

  Formtastic::SemanticFormHelper.builder = ClassyEnum::SemanticFormBuilder

  # Copied from how formtastic tests its form helpers
  before do
    @output_buffer = ""
  end

  context "when building a form with a classy_enum select" do
    context "with an object that has the enum set" do
      before(:each) do
        @output = semantic_form_for(Dog.new(:breed => :snoop), :url => "/") do |builder|
          concat(builder.input(:breed, :as => :enum_select))
        end
      end

      it "should produce an unselected option tag for Golden Retriever" do
        regex = Regexp.new("<option value=\\\"golden_retriever\\\">Golden Retriever")
        @output.should =~ regex
      end

      it "should produce a selected option tag for Snoop" do
        regex = Regexp.new("<option value=\\\"snoop\\\" selected=\\\"selected\\\">Snoop")
        @output.should =~ regex
      end

      it "should not produce a blank selected option tag" do
        regex = Regexp.new("<option value=\"\"><")
        @output.should_not =~ regex
      end
    end

    context "with an object that has a nil enum" do
      before(:each) do
        @output = semantic_form_for(Dog.new, :url => "/") do |builder|
          concat(builder.input(:breed, :as => :enum_select))
        end
      end

      it "should produce an unselected option tag for Golden Retriever" do
        regex = Regexp.new("<option value=\\\"golden_retriever\\\">Golden Retriever")
        @output.should =~ regex
      end

      it "should not produce an selected option tag" do
        regex = Regexp.new("selected")
        @output.should_not =~ regex
      end

    end

    context "with an object with a different attribute name which requires the enum_class" do
      before(:each) do
        @output = semantic_form_for(OtherDog.new, :url => "/") do |builder|
          concat(builder.input(:other_breed, :as => :enum_select, :enum_class => :breed))
        end
      end

      it "should produce an unselected option tag for Golden Retriever" do
        regex = Regexp.new("<option value=\\\"golden_retriever\\\">Golden Retriever")
        @output.should =~ regex
      end

      it "should not produce an selected option tag" do
        regex = Regexp.new("selected")
        @output.should_not =~ regex
      end

    end

  end

  it "should raise an error if the attribute is not a ClassyEnum object" do
    lambda do
      @output = semantic_form_for(Dog.new(:breed => :snoop), :url => "/") do |builder|
        concat(builder.input(:id, :as => :enum_select))
      end
    end.should raise_error("id is not a ClassyEnum object. Make sure you've added 'classy_enum_attr :id' to your model")
  end

  it "should raise an error if the attribute is not a ClassyEnum object and its value is nil" do
    lambda do
      @output = semantic_form_for(Dog.new, :url => "/") do |builder|
        concat(builder.input(:id, :as => :enum_select))
      end
    end.should raise_error("id is not a ClassyEnum object. Make sure you've added 'classy_enum_attr :id' to your model")
  end

end

