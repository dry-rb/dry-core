---
title: Class Builder
layout: gem-single
name: dry-core
---

```ruby
require 'dry/core/class_builder'

builder = Dry::Core::ClassBuilder.new(name: 'MyClass')

klass = builder.call
klass.name # => "MyClass"
```
