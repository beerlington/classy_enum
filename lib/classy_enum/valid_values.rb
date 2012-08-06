module ClassyEnum
  module ValidValues
    def valid? value
      self.base_class.valid? value
    end

    def valid_values
      self.base_class.valid_values
    end
  end
end
