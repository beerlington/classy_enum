class ClassyEnumGenerator < Rails::Generators::NamedBase
  desc "Generate a ClassyEnum definition in app/enums/"

  argument :name, :type => :string, :required => true, :banner => 'EnumName'
  argument :values, :type => :array, :default => [], :banner => 'value1 value2 value3 etc...'
  class_option :macro, :type => :boolean, :default => false, :banner => 'Generate enums as macro calls'

  source_root File.expand_path("../templates", __FILE__)

  def copy_files # :nodoc:
    empty_directory 'app/enums'
    template "#{template_name}.rb", "app/enums/#{file_name}.rb"
  end

  protected

  def template_name
    macro? 'macro_enum' : 'enum'
  end

  def macro?
    options[:macro]
  end
end
