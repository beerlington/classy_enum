# ClassyEnum Changelog

## 2.0.0

* Enum class definitions are no longer defined implicity and must be explicitly subclassed from children of ClassyEnum::Base

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
