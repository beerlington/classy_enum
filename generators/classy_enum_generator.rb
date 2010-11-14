class ClassyEnumGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m| 
      m.directory 'app/enums'
      m.template "enum.rb", "app/enums/#{file_name}.rb"
    end
  end

end
