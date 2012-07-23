require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Legacy < ClassyEnum::Base
end

class LegacyOne < Legacy
end

class LegacyTwo < Legacy
end

class LegacyThree < Legacy
end

describe Legacy do
  it 'should not break' do
    
  end
end
