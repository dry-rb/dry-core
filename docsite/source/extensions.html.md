---
title: Extensions
layout: gem-single
name: dry-core
---

Define extensions that can be later enabled by the user.

```ruby
require "dry/core"

class Foo
  extend Dry::Core::Extensions

  register_extension(:bar) do
     def bar; :bar end
  end
end

Foo.new.bar # => NoMethodError
Foo.load_extensions(:bar)
Foo.new.bar # => :bar
```
