require "classy_enum/attributes"

if Gem.available? 'formtastic'
  require 'formtastic' 
  require 'classy_enum/semantic_form_builder'
end

module ClassyEnum

  def enum_classes(*options)
    self.send(:attr_reader, :enum_classes)

    self.const_set("OPTIONS", options) unless self.const_defined? "OPTIONS"
    self.const_set("OPTION_HASH", Hash.new) unless self.const_defined? "OPTION_HASH"

    self.extend SuperClassMethods

    options.each do |option|

      klass = Class.new(self) do
        self.send(:attr_reader, :to_s, :to_sym, :index, :base_class)
        
        def initialize(base_class, option, index)
          @to_s = option.to_s.downcase
          @to_sym = @to_s.to_sym
          @index = index + 1
          @base_class = base_class
        end

        def name
          to_s.titleize
        end

        def <=> other
          @index <=> other.index
        end
      end
      
      Object.const_set("#{self}#{option.to_s.camelize}", klass)
    
      instance = klass.new(self, option, options.index(option))
      
      self::OPTION_HASH[option] = instance
    end
  end

  # Added to give someone the option to extend or include with same functionality
  def self.included(klass)
    klass.send(:extend, ClassyEnum)
  end

  module SuperClassMethods
      
    def build(option)
      return nil if option.nil?
      self::OPTION_HASH[option.to_sym] || TypeError.new("Valid #{self} options are #{self.valid_options}")
    end
    
    # Alias of new
    def find(option)
      build(option)
    end

    def all
      self::OPTIONS.map {|e| build(e) }
    end
    
    # Uses the name field for select options
    def all_with_name
      all.map {|e| [e.name, e.to_s] }
    end
    
    def valid_options
      self::OPTIONS.map(&:to_s).join(', ')
    end
  
  end

end
