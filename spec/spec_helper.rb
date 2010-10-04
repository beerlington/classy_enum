$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'spec'

require 'active_record'
require 'action_view'
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
