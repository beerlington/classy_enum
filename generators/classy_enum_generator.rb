class ClassyEnumGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m| 
      m.directory 'app/enums'
      m.template "enum.erb", "app/enums/#{file_name}.rb"
    end
  end

end
