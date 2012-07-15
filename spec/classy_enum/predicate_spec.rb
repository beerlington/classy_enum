require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ClassyEnumPredicate < ClassyEnum::Base
end

class ClassyEnumPredicateOne < ClassyEnumPredicate
end

class ClassyEnumPredicateTwo < ClassyEnumPredicate
end

describe ClassyEnum::Predicate do
  context '#attribute?' do
    specify { ClassyEnumPredicateOne.new.should be_one }
    specify { ClassyEnumPredicateOne.new.should_not be_two }
    specify { ClassyEnumPredicateTwo.new.should_not be_one }
    specify { ClassyEnumPredicateTwo.new.should be_two }
  end
end
