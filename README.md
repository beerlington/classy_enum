# ClassyEnum

[![Build Status](https://travis-ci.org/beerlington/classy_enum.svg?branch=master)](https://travis-ci.org/beerlington/classy_enum)
[![Gem Version](https://badge.fury.io/rb/classy_enum.png)](http://badge.fury.io/rb/classy_enum)
[![Code Climate](https://codeclimate.com/github/beerlington/classy_enum/badges/gpa.svg)](https://codeclimate.com/github/beerlington/classy_enum)
[![Dependency Status](https://gemnasium.com/beerlington/classy_enum.svg)](https://gemnasium.com/beerlington/classy_enum)

ClassyEnum is a Ruby on Rails gem that adds class-based enumerator functionality to Active Record attributes.

This README is also available in a [user-friendly DocumentUp format](http://beerlington.com/classy_enum/).

## Rails & Ruby Versions Supported

*Rails:* 3.2.x - 4.2.x

*Ruby:* 1.9.3, 2.0.0, 2.1.x, and 2.2.x

## Installation

The gem is hosted at [rubygems.org](https://rubygems.org/gems/classy_enum)

## Upgrading?

See the [wiki](https://github.com/beerlington/classy_enum/wiki/Upgrading) for notes about upgrading from previous versions.

## Getting Started & Example Usage

The most common use for ClassyEnum is to replace database lookup tables where the content and behavior is mostly static and has multiple "types". Please see the Wiki for a short discussion on use cases [comparing ClassyEnum to other gems](https://github.com/beerlington/classy_enum/wiki/ClassyEnum-vs-other-gems).

In this example, I have an Active Record model called `Alarm` with an attribute called `priority`. Priority is stored as a string (VARCHAR) type in the database and is converted to an enum value when requested.

### 1. Generate the Enum

The fastest way to get up and running with ClassyEnum is to use the built-in Rails generator like so:

```
rails generate classy_enum Priority low medium high
```

NOTE: You may destroy/revoke an enum by using the `rails destroy`
command:

```
rails destroy classy_enum Priority
```

A new enum template file will be created at app/enums/priority.rb that will look like:

```ruby
class Priority < ClassyEnum::Base
end

class Priority::Low < Priority
end

class Priority::Medium < Priority
end

class Priority::High < Priority
end
```

NOTE: The class order is important because it defines the enum member ordering as well as additional ClassyEnum behavior described below.

### 2. Customize the Enum

The generator creates a default setup, but each enum member can be changed to fit your needs.

I have defined three priority levels: low, medium, and high. Each priority level can have different properties and methods associated with it.

I would like to add a method called `#send_email?` that all member subclasses respond to. By default this method will return false, but will be overridden for high priority alarms to return true.

```ruby
class Priority < ClassyEnum::Base
  def send_email?
    false
  end
end

class Priority::Low < Priority
end

class Priority::Medium < Priority
end

class Priority::High < Priority
  def send_email?
    true
  end
end
```

### 3. Setup the Active Record model

My Active Record Alarm model needs a text field that will store a string representing the enum member. An example model schema might look something like:

```ruby
create_table "alarms", force: true do |t|
  t.string   "priority"
  t.boolean  "enabled"
end
```

NOTE: Alternatively, you may use an enum type if your database supports it. See
[this issue](https://github.com/beerlington/classy_enum/issues/12) for more information.

Then in my model I've included `ClassyEnum::ActiveRecord` and added a line that calls `classy_enum_attr` with a single argument representing the enum I want to associate with my model. I am also delegating the `#send_email?` method to my Priority enum class.

```ruby
class Alarm < ActiveRecord::Base
  include ClassyEnum::ActiveRecord

  classy_enum_attr :priority

  delegate :send_email?, to: :priority
end
```

With this setup, I can now do the following:

```ruby
@alarm = Alarm.create(priority: :medium)

@alarm.priority  # => Priority::Medium
@alarm.priority.medium? # => true
@alarm.priority.high? # => false
@alarm.priority.to_s # => 'medium'

# Should this alarm send an email?
@alarm.send_email? # => false
@alarm.priority = :high
@alarm.send_email? # => true
```

The enum field works like any other model attribute. It can be mass-assigned using `#update_attributes`.

#### What if your enum class name is not the same as your model's attribute name?

Just provide an optional `class_name` argument to declare the enum's class name. In this case, the model's attribute is called *alarm_priority*.

```ruby
class Alarm < ActiveRecord::Base
  include ClassyEnum::ActiveRecord

  classy_enum_attr :alarm_priority, class_name: 'Priority'
end

@alarm = Alarm.create(alarm_priority: :medium)
@alarm.alarm_priority  # => Priority::Medium
```

## Internationalization

ClassyEnum provides built-in support for translations using Ruby's I18n
library. The translated values are provided via a `#text` method on each
enum object. Translations are automatically applied when a key is found
at `locale.classy_enum.enum_parent_class.enum_value`, or a default value
is used that is equivalent to `#to_s.titleize`.

Given the following file *config/locales/es.yml*

```yml
es:
  classy_enum:
    priority:
      low: 'Bajo'
      medium: 'Medio'
      high: 'Alto'
```

You can now do the following:

```ruby
@alarm.priority = :low
@alarm.priority.text # => 'Low'

I18n.locale = :es

@alarm.priority.text # => 'Bajo'
```

## Using Enum as a Collection

ClassyEnum::Base extends the [Enumerable module](http://ruby-doc.org/core-2.1.3/Enumerable.html)
which provides several traversal and searching methods. This can
be useful for situations where you are working with the collection,
as opposed to the attributes on an Active Record object.

```ruby
# Find the priority based on string or symbol:
Priority.find(:low) # => Priority::Low.new
Priority.find('medium') # => Priority::Medium.new

# Test if a priority is valid:
Priority.include?(:low) # => true
Priority.include?(:lower) # => false

# List priorities base strings:
Priority.map { |p| p.to_s } # => ["low", "medium", "high"]

# Find the lowest priority that can send email:
Priority.find(&:send_email?) # => Priority::High.new

# Find the priorities that are lower than Priority::High
Priority.select {|p| p < :high } # => [Priority::Low.new, Priority::Medium.new]

# Iterate over each priority:
Priority.each do |priority|
  puts priority.send_email?
end
```

## Default Enum Value

As with any Active Record attribute, default values can be specified in
the database table and will propagate to new instances. However, there
may be times when you can't or don't want to set the default value in
the database. For these occasions, a default value can be specified like
so:

```ruby
class Alarm < ActiveRecord::Base
  include ClassyEnum::ActiveRecord

  classy_enum_attr :priority, default: 'medium'
end

Alarm.new.priority # => Priority::Medium
```

You may also use a Proc object to set the default value. The enum class
is yielded to the block and can be used to determine the default at
runtime.

```ruby
class Alarm < ActiveRecord::Base
  include ClassyEnum::ActiveRecord

  classy_enum_attr :priority, default: ->(enum){ enum.max }
end

Alarm.new.priority # => Priority::High
```

## Back Reference to Owning Object

In some cases you may want an enum class to reference the owning object
(an instance of the Active Record model). Think of it as a `belongs_to`
relationship, where the enum belongs to the model.

By default, the back reference can be called using `#owner`.
If you want to refer to the owner by a different name, you must explicitly declare
the owner name in the classy_enum parent class using the `.owner` class method.

Example using the default `#owner` method:

```ruby
class Priority < ClassyEnum::Base
end

# low and medium subclasses omitted

class Priority::High < Priority
  def send_email?
    owner.enabled?
  end
end
```

Example where the owner reference is explicitly declared:

```ruby
class Priority < ClassyEnum::Base
  owner :alarm
end

# low and medium subclasses omitted

class Priority::High < Priority
  def send_email?
    alarm.enabled?
  end
end
```

In the above examples, high priority alarms are only emailed if the owning alarm is enabled.

```ruby
@alarm = Alarm.create(priority: :high, enabled: true)

# Should this alarm send an email?
@alarm.send_email? # => true
@alarm.enabled = false
@alarm.send_email? # => false
```

## Model Validation

An Active Record validator `validates_inclusion_of :field, in: ENUM` is automatically added to your model when you use `classy_enum_attr`.

If your enum only has members low, medium, and high, then the following validation behavior would be expected:

```ruby
@alarm = Alarm.new(priority: :really_high)
@alarm.valid? # => false
@alarm.priority = :high
@alarm.valid? # => true
```

To allow nil or blank values, you can pass in `:allow_nil` and `:allow_blank` as options to `classy_enum_attr`:

```ruby
class Alarm < ActiveRecord::Base
  include ClassyEnum::ActiveRecord

  classy_enum_attr :priority, allow_nil: true
end

@alarm = Alarm.new(priority: nil)
@alarm.valid? # => true
```

## Form Usage

ClassyEnum includes a `select_options` helper method to generate an array of enum options
that can be used by Rails' form builders such as SimpleForm and Formtastic.

```erb
# SimpleForm

<%= simple_form_for @alarm do |f| %>
  <%= f.input :priority, as: :select, collection: Priority.select_options %>
  <%= f.button :submit %>
<% end %>
```

## Testing Enums

ClassyEnums can be tested by creating new instances of the ClassyEnum and
testing expectations. For example:

``` ruby
class TestPriorityHigh < Minitest::Test
  def setup
    @priority_high_enum = Priority::High.new
  end

  def test_send_email_enabled
    assert @priority_high_enum.send_email?
  end
end
```

If the ClassyEnum method implementations rely upon the owner, the
`ClassyEnum#build` method can be used with the `owner` option. For example:

``` ruby
class TestPriorityHigh < Minitest::Test
  def setup
    @alarm = Alarm.create
    @priority_high_enum = Priority::High.build(:high, owner: @alarm)
  end

  def test_send_email_enabled
    assert_equal @priority_high_enum.owner, @alarm
  end
end
```

## Copyright

Copyright (c) 2010-2014 [Peter Brown](https://github.com/beerlington). See LICENSE for details.
