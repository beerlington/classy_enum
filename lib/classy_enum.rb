module ClassyEnum
  autoload :Base, 'classy_enum/base'
  autoload :InstanceMethods, 'classy_enum/instance_methods'
  autoload :ClassMethods, 'classy_enum/class_methods'
  autoload :Attributes, 'classy_enum/attributes'
end

ActiveRecord::Base.send :extend, ClassyEnum::Attributes
