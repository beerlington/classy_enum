require 'classy_enum/macros'

enum_for :<%= class_name.underscore %>, <%= values.map(&:to_sym).inspect %>