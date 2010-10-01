require "classy_enum/classy_enum_attributes"

class ClassyEnumValue < Object 
 
  attr_reader :to_s, :index

  def initialize(option, index)
    @to_s = option.to_s.downcase
    @index = index + 1
  end
  
  def name
    to_s.titleize
  end
  
  def <=> other
    @index <=> other.index
  end

end

module ClassyEnum
    
  module ClassMethods
      
    def new(option)
      self::OPTION_HASH[option] || TypeError.new("Valid #{self} options are #{self.valid_options}")
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
    other.extend ClassMethods
    
    other.const_set("OPTION_HASH", Hash.new)

    other::OPTIONS.each do |option|

      klass = Class.new(ClassyEnumValue) do
        include other::InstanceMethods if other.const_defined?("InstanceMethods")
        extend other::ClassMethods if other.const_defined?("ClassMethods")
      end

      Object.const_set("#{other}#{option.to_s.camelize}", klass)
    
      instance = klass.new(option, other::OPTIONS.index(option))
      
      other::OPTION_HASH[option] = other::OPTION_HASH[option.to_s.downcase] = instance
      
      ClassyEnum.const_set(option.to_s.upcase, instance) unless ClassyEnum.const_defined?(option.to_s.upcase)
    end

  end
  
end


