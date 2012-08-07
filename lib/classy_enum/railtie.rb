module ClassyEnum
  module Rails
    module Railtie < ::Rails::Railtie
      initializer "classy enum" do |app|
        ActiveSupport::Dependencies.autoload_paths << "#{Rails.root}/app/enums"
      end
    end
  end
end