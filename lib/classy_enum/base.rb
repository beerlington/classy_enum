module ClassyEnum
  class Base
    extend ClassyEnum::ClassMethods
    include ClassyEnum::InstanceMethods
    include Comparable

    class_attribute :enum_options, :base_class
    attr_accessor :owner, :serialize_as_json
  end
end
