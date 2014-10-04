module Rspec
  module Generators
    class ClassyEnumGenerator < Rails::Generators::NamedBase
      desc "Generate a ClassyEnum spec in spec/enums/"

      argument :name, type: :string, required: true, banner: 'EnumName'
      argument :values, type: :array, default: [], banner: 'value1 value2 value3 etc...'

      source_root File.expand_path("../templates", __FILE__)

      def copy_files # :nodoc:
        template "enum_spec.rb", "spec/enums/#{file_name}_spec.rb"
      end
    end
  end
end
