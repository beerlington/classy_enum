require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ClassyEnumPredicate < ClassyEnum::Base
end

class ClassyEnumPredicate::One < ClassyEnumPredicate
end

class ClassyEnumPredicate::Two < ClassyEnumPredicate
end

describe ClassyEnum::Predicate do
  context '#attribute?' do
    specify { ClassyEnumPredicate::One.new.should be_one }
    specify { ClassyEnumPredicate::One.new.should_not be_two }
    specify { ClassyEnumPredicate::Two.new.should_not be_one }
    specify { ClassyEnumPredicate::Two.new.should be_two }
  end
end
