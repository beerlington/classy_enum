require "classy_enum/attributes"

if Gem.available? 'formtastic'
  require 'formtastic' 
  require 'classy_enum/semantic_form_builder'
end

module ClassyEnum

  class Base
    def self.enum_classes(*options)
      self.send(:attr_reader, :enum_classes)

      self.const_set("OPTIONS", options) unless self.const_defined? "OPTIONS"

      self.extend ClassMethods

      options.each_with_index do |option, index|

        klass = Class.new(self) do
          attr_reader :to_s, :to_sym, :index

          @index = index + 1
          @option = option

          def initialize
            @to_s = self.class.instance_variable_get('@option').to_s
            @to_sym = @to_s.to_sym
            @index = self.class.instance_variable_get('@index')
          end

          def name
            @to_s.titleize
          end

          def <=> other
            @index <=> other.index
          end
        end

        klass_name = "#{self}#{option.to_s.camelize}"
        Object.const_set(klass_name, klass) unless Object.const_defined? klass_name
      end
    end
  end

  module ClassMethods
      
    def build(option)
      return option if option.blank?
      return TypeError.new("Valid #{self} options are #{self.valid_options}") unless self::OPTIONS.include? option.to_sym
      Object.const_get("#{self}#{option.to_s.camelize}").new
    end
    
    # Alias of build
    def find(option); build(option); end;

    def all
      self::OPTIONS.map {|e| build(e) }
    end
    
    # Uses the name field for select options
    def select_options
      all.map {|e| [e.name, e.to_s] }
    end
    
    def valid_options
      self::OPTIONS.map(&:to_s).join(', ')
    end
  
  end

end
