require 'classy_enum/collection'
require 'classy_enum/conversion'
require 'classy_enum/predicate'
require 'classy_enum/base'

require 'classy_enum/adaptor/active_record' if defined?(ActiveRecord::Base)
require 'classy_enum/adaptor/mongoid' if defined?(Mongoid)
require 'classy_enum/adaptor/mongo_mapper' if defined?(MongoMapper)
