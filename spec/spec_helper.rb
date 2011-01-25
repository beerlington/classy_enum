$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'active_record'
require 'active_support'
require 'action_pack'
require 'action_view'
require 'action_controller'
require 'formtastic'
require 'classy_enum'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define(:version => 1) do
  create_table :dogs, :force => true do |t|
    t.string :breed
    t.string :other_breed
  end

  create_table :things, :force => true do |t|
    t.string :dog_breed
  end
end

class Breed < ClassyEnum::Base
  enum_classes :golden_retriever, :snoop
end

class Dog < ActiveRecord::Base
  classy_enum_attr :breed
  classy_enum_attr :breed, :other_breed
end

module FormtasticSpecHelper
  include ActionView::Context if defined?(ActionView::Context)
  include ActionController::RecordIdentifier
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include Formtastic::SemanticFormHelper

  def self.included(base)
    base.class_eval do

      attr_accessor :output_buffer

      def protect_against_forgery?
        false
      end

    end
  end

end

module ActionView
  class OutputBuffer < ActiveSupport::SafeBuffer
  end
end

