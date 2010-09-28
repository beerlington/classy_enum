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
      klass = Class.new(ClassyEnumValue) {
        include other::Defaults if other.const_defined?("Defaults")
      }

      Object.const_set("#{other}#{option.to_s.camelize}", klass)
    
      instance = klass.new(option, other::OPTIONS.index(option))
      
      other::OPTION_HASH[option] = other::OPTION_HASH[option.to_s.downcase] = instance
      
      ClassyEnum.const_set(option.to_s.upcase, instance) unless ClassyEnum.const_defined?(option.to_s.upcase)
    end

  end
  
end

module ClassyEnumAttributes
  module ClassMethods
    def classy_enum_attr(klass, method=nil)
      
      method ||= klass
      
      klass = klass.to_s.camelize.constantize
      
      # Add ActiveRecord validation to ensure it won't be saved unless it's an option
      self.send(:validates_inclusion_of, method, :in => klass.all)
      
      self.instance_eval do
        
        # Define getter method
        define_method method do
          klass.new(super)
        end
        
        # Define setter method
        define_method "#{method}=" do |value|
          super value.to_s
        end
        
      end
      
    end
  end
  
  def self.included(other)
    other.extend ClassMethods
  end
  
end

ActiveRecord::Base.send :include, ClassyEnumAttributes