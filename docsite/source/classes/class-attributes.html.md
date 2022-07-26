---
title: Class Attributes
layout: gem-single
name: dry-core
---

```ruby
require 'dry/core/class_attributes'

class ExtraClass
  extend Dry::Core::ClassAttributes

  defines :hello

  hello 'world'
end

# example with inheritance and type checking
# setting up an invalid value will raise Dry::Core::InvalidClassAttributeValueError

class MyClass
  extend Dry::Core::ClassAttributes

  defines :one, :two, type: Integer

  one 1
  two 2
end

class OtherClass < MyClass
  two 3
end

MyClass.one # => 1
MyClass.two # => 2

OtherClass.one # => 1
OtherClass.two # => 3

# example type checking with dry-types

class Foo
  extend Dry::Core::ClassAttributes

  defines :one, :two, type: Dry::Types['strict.integer']
end
```
