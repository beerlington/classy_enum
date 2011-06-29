module ActiveRecord # :nodoc: all
  class PredicateBuilder
    def build_from_hash_with_classy_enum(attributes, default_table)

      # Convert classy enum values to strings
      attributes.each do |column, value|
        attributes[column] = value.to_s if value.is_a? ClassyEnum::Base
      end

      build_from_hash_without_classy_enum(attributes, default_table)
    end

    alias_method_chain :build_from_hash, :classy_enum
  end
end
