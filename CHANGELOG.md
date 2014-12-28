# ClassyEnum Changelog

## 4.0.0

* Adds support for Ruby 2.2.0
* Adds support for Rails 4.2.0
* [BREAKING] Removes support for Ruby 1.8.7
* [BREAKING] Removes support for Rails 3.0.x and 3.1.x
* [BREAKING] Active Record models must explicitly include ClassyEnum::ActiveRecord now
* [BREAKING] Removed use of null objects. Blank values are now returned as is from Enum.build.
* [BREAKING] Removed serialize_as_json option. #as_json should be overriden in ClassyEnum::Base subclasses instead.
* [BREAKING] Removed allow_blank option from Enum.build. This was used internally for legacy reasons and is no longer needed.
* [BREAKING] Fixes support for ActiveModel::Dirty. Now dirty attribute methods always return enum class instance (instead of string).
* Prefer 'class_name' over 'enum' as optional class name argument

## 3.5.0

* Fixes long standing issue with default values not being persisted to
  the database. See issue #37.
* Updates `classy_enum_attr` method to accept class_name as an argument as
  an alias for `enum`. This is to bring the API closer to how
  ActiveRecord overrides class names on associations.

```ruby
class Alarm < ActiveRecord::Base
  classy_enum_attr :priority, enum: 'AlarmPriority'
end
```

is now equivalent to:

```ruby
class Alarm < ActiveRecord::Base
  classy_enum_attr :priority, class_name: 'AlarmPriority'
end
```


## 3.4.0

* Removes full Rails gem dependency in favor of ActiveRecord

## 3.3.2

* Fixes `rails destroy classy_enum MyEnum` for test unit
* Fixes edge case support for Arel 4.0.1 internal change

## 3.3.1

* Fixes `rails destroy classy_enum MyEnum` so it does not remove enums
  directory and inadvertently remove all enum classes.
* Adding license to gemspec

## 3.3.0

* Extends the existing generator to create boilerplate spec/test files.
  For Rspec, these files are placed in spec/enums/, for TestUnit, they
  are placed in test/unit/enums/

## 3.2.1

* Better support for using `default` and `allow_*` options together
* Fixes bug when using `default` option and explicitly setting value to
  nil if `allow_nil: true` option is not used.
* Fixes bug when chaining `count` onto scope that uses enum object in
  query condition.

## 3.2.0

* Default values can now be specified within an ActiveRecord model

```ruby
class Alarm < ActiveRecord::Base
  classy_enum_attr :priority, :default => 'medium'
end

class Alarm < ActiveRecord::Base
  classy_enum_attr :priority, :default => lambda {|enum| enum.last }
end
```

* Adding ClassyEnum::Base#last. It's not part of the enumerable module
  but it makes sense in this case.

```ruby
Priority.last # => Priority::High
```

## 3.1.3

* Fixes saving and reloading ActiveRecord models that assign enum using
  class

## 3.1.2

* Allow enum property to be assigned using enum class. Previously it
  could only be assigned with an instance, string or symbol.

```ruby
@alarm.priority = Priority::Medium
@alarm.priority.medium? # => true
```

## 3.1.1

* Fixes a regression with Formtastic support. ClassyEnumm::Base.build now
  returns a null object that decends from the base_class when the argument is
  blank (nil, empty string, etc). This allows the ActiveRecord model's enum
  attribute to respond to enum methods even if it is blank.

## 3.1.0

* ClassyEnum::Base now extends Enumerable to provide enum collection
  methods. All objects in the collection are instances of the enum
  members. .find is overridden to provide custom find functionality.
* ClassyEnum::Base.find has been reintroduced, with aliases of .detect
  and [].
* Introducing I18n support and providing a ClassyEnum::Base#text method
  that will automatically translate text values.
* Translation support was added to ClassyEnum::Base.select_options.
* Equality can now be determined using strings and symbols. The
  following will return true:

```ruby
Priority::Low.new == :low  # => true
Priority::Low.new == 'low' # => true
```

## 3.0.0

* Removing ClassyEnum::Base.enum_classes in favor of using enum
  inheritance to setup classes
* Removing ClassyEnum::Base.valid_options
* Removing ClassyEnum::Base.find
* Removing ClassyEnum::Base#name
* Removing :suffix option from classy_enum_attr
* Enforce use of namespacing for subclasses (Parent::Child < Parent)
* Use require instead of autoload
* Lots of code refactoring

## 2.3.0

* Deprecating ClassyEnum::Base#name (use to_s.titleize instead). `name` is
  too ambiguous and might get confused with Ruby's Class.name method.
* Deprecating :suffix option from classy_enum_attr (this was a temporary
  hack)

## 2.2.0

* Deprecating class names like ParentChild in favor of namespaced names
  like Parent::Child

## 2.1.0

* Deprecating ClassyEnum::Base.enum_classes (this is no longer needed)
* Deprecating ClassyEnum::Base.valid_options (use all.join(', ') instead)
* Deprecating ClassEnum::Base.find (use build() instead)

## 2.0.3

* Fixes issue with validates_uniqueness_of when using an enum field as
  the scope.

## 2.0.1 & 2.0.2

* Resolving gem release conflicts, no changes

## 2.0.0

* Enum class definitions are no longer defined implicitly and must be explicitly subclassed from children of ClassyEnum::Base
* Formtastic support is not longer built-in. See https://github.com/beerlington/classy_enum/wiki/Formtastic-Support
* validates_uniqueness_of with an enum scope no longer works in Rails
  3.0.x (no changes for Rails 3.1 or 3.2)

## 1.3.2

* Added support for Ruby 1.9.3
* Stop hijacking enum initialize method

## 1.3.1

* Fixed JSON recursion issue

## 1.3.0

* Added support for Rails 3.1.x

## 1.2.0

* Added support for owner enum reference

## 1.1.0

* Code refactor

## 1.0.0

* Removed support for Rails 2.x.x
* Fixed support for validates_uniqueness_of with an enum scope

## 0.9.1

* Fixed Rails dependency requirement

## 0.9.0

* Further decoupled Formtastic support

## 0.8.1

* Added `:allow_blank` option
* Added blank/nil option support to Formtastic
* Fixed documentation typos

## 0.8.0

* Updated development dependencies
* Changed API for column and enum name differences

## 0.7.1

* Added Comparable support
* Fixed an issue with invalid objects set to empty string
* Added allow blank support to Formtastic
* Improved error messages

## 0.7.0

* Added "boolean" methods (i.e. `instance.enum?`)
* Improved documentation
* Updated generators to make inheritance more explicit
* Removed ActiveRecord dependency

## 0.6.1

* Fixed validates_presence_of support
* Improved Formtastic support

## 0.6.0

* Changed enums to use inheritance instead of mixins
* Fixed issue with generators
* Fixed documentation typos

## 0.5.0

* Fixed documentation

## 0.4.2

* Cleaned up hacky support for Rails 3.0.x
* Fixed Formtastic load support

## 0.4.1

* Fixed validation issue in Rails 3.0.x

## 0.4.0

* Added enum generator for Rails 3.0.x
* Added support for Ruby 1.9.2
* Fixed support for apps that are not using Formtastic

## 0.3.1

* Fixed Formtastic helper support w/ Rails 3.0.x

## 0.3.0

* Added custom Formtastic input type

## 0.2.0

* Internal changes to how methods are defined

## 0.1.0

* Added enum generator for Rails 2.3.x
* Internal changes to how ActiveRecord is extended
* More test coverage

## 0.0.2

* Fixed initialized constant warning

## 0.0.1

* Initial Release
