require 'classy_enum/adaptor/base'

Mongoid::Document.send :include, ClassyEnum::Adaptor::Base