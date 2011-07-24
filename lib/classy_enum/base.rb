module ClassyEnum
  class Base
    extend ClassyEnum::ClassMethods
    include ClassyEnum::InstanceMethods
    include Comparable
    include ActiveModel::AttributeMethods
  end
end
