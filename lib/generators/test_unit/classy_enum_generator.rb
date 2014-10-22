module TestUnit
  module Generators
    class ClassyEnumGenerator < Rails::Generators::NamedBase
      desc "Generate a ClassyEnum test in test/enums/"

      argument :name, type: :string, required: true, banner: 'EnumName'
      argument :values, type: :array, default: [], banner: 'value1 value2 value3 etc...'

      source_root File.expand_path("../templates", __FILE__)

      def copy_files # :nodoc:
        template "enum_test.rb", "test/enums/#{file_name}_test.rb"
      end
    end
  end
end
