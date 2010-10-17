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
  end

  create_table :things, :force => true do |t|
    t.string :dog_breed
  end
end

module Breed
  OPTIONS = [:golden_retriever, :snoop]
  
  include ClassyEnum
end

class Dog < ActiveRecord::Base
  classy_enum_attr :breed
end

module FormtasticSpecHelper
  include ActionPack
  include ActionView::Context if defined?(ActionView::Context)
  include ActionController::RecordIdentifier
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::AssetTagHelper
  include ActiveSupport
  include ActionView::Helpers::ActiveRecordHelper if defined?(ActionView::Helpers::ActiveRecordHelper)
  include ActionView::Helpers::ActiveModelHelper if defined?(ActionView::Helpers::ActiveModelHelper)
  include ActionController::PolymorphicRoutes if defined?(ActionController::PolymorphicRoutes)
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

