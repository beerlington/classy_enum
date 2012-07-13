module ClassyEnum
  class Base
    extend ClassyEnum::ClassMethods
    include ClassyEnum::InstanceMethods
    include Comparable
    include ActiveModel::AttributeMethods

    class_attribute :enum_options, :base_class
    attribute_method_suffix '?'
    attr_accessor :owner, :serialize_as_json
  end
end
