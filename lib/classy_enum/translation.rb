require 'i18n'

module ClassyEnum
  module Translation

    # Returns a translated string of the enum type. Used internally to create
    # the select_options array.
    #
    # Translation location is:
    # locale.classy_enum.base_class.enum_string
    #
    # ==== Example
    #  # Create an Enum with some elements
    #  class Priority < ClassyEnum::Base
    #  end
    #
    #  class Priority::Low < Priority; end
    #  class Priority::ReallyHigh < Priority; end
    #
    #  # Default translations are `to_s.titlieze`
    #  Priority::Low.new.text # => 'Low'
    #  Priority::ReallyHigh.new.text # => 'Really High'
    #
    #  # Assuming we have a translation defined for:
    #  # es.classy_enum.priority.low # => 'Bajo'
    #
    #  Priority::Low.new.text # => 'Bajo'
    def text
      I18n.translate to_s, scope: i18n_scope, default: to_s.titleize
    end

    private

    def i18n_scope
      [:classy_enum, base_class.name.underscore]
    end
  end
end
