require "classy_enum/attributes"

if Gem.available? 'formtastic'
  require 'formtastic' 
  require 'classy_enum/semantic_form_builder'
end

module ClassyEnum
    
  module SuperClassMethods
      
    def new(option)
      return nil if option.nil?
      self::OPTION_HASH[option.to_sym] || TypeError.new("Valid #{self} options are #{self.valid_options}")
    end
    
    def all
      self::OPTIONS.map {|e| self.new(e) }
    end
    
    # Uses the name field for select options
    def all_with_name
      self.all.map {|e| [e.name, e.to_s] }
    end
    
    def valid_options
      self::OPTIONS.map(&:to_s).join(', ')
    end
    
    # Alias of new
    def find(option)
      new(option)
    end
  
  end
  
  def self.included(other)
    other.extend SuperClassMethods
    
    other.const_set("OPTION_HASH", Hash.new) unless other.const_defined? "OPTION_HASH"

    other::OPTIONS.each do |option|

      klass = Class.new do
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
        
        include other::InstanceMethods if other.const_defined?("InstanceMethods")
        extend other::ClassMethods if other.const_defined?("ClassMethods")
      end

      Object.const_set("#{other}#{option.to_s.camelize}", klass)
    
      instance = klass.new(other, option, other::OPTIONS.index(option))
      
      other::OPTION_HASH[option] = instance
      
      ClassyEnum.const_set(option.to_s.upcase, instance) unless ClassyEnum.const_defined?(option.to_s.upcase)
    end

  end
  
end


