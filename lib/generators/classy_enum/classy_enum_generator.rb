class ClassyEnumGenerator < Rails::Generators::NamedBase
  desc "Generate a ClassyEnum definition in app/enums/"

  argument :name, :type => :string, :required => true, :banner => 'EnumName'
  argument :values, :type => :array, :default => [], :banner => 'value1 value2 value3 etc...'

  source_root File.expand_path("../templates", __FILE__)

  def copy_files # :nodoc:
    empty_directory 'app/enums'
    template "enum.rb", "app/enums/#{file_name}.rb"
  end

  hook_for :test_framework
end
