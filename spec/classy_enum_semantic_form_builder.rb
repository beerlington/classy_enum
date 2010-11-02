require "spec/spec_helper"

describe 'using enum_select input' do 
  include FormtasticSpecHelper
  
  Formtastic::SemanticFormHelper.builder = ClassyEnum::SemanticFormBuilder

  context "when building a form with a classy_enum select" do
    before(:each) do
      @output_buffer = ""
      @output = semantic_form_for(Dog.new(:breed => :snoop), :url => "/") do |builder| 
        concat(builder.input(:breed, :as => :enum_select)) 
      end 
    end

    it "should produce a form tag" do
      @output.should =~ /<form/
    end

    it "should produce an unselected option tag for Golden Retriever" do
      regex = Regexp.new("<option value=\\\"golden_retriever\\\">Golden Retriever")
      @output.should =~ regex
    end

    it "should produce an selected option tag for Snoop" do
      regex = Regexp.new("<option value=\\\"snoop\\\" selected=\\\"selected\\\">Snoop")
      @output.should =~ regex
    end
  end

end 

