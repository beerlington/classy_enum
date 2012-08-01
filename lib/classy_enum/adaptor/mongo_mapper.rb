require 'classy_enum/adaptor/base'

MongoMapper::Document.send :include, ClassyEnum::OrmAdaptor