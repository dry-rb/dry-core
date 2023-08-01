---
title: Cache
layout: gem-single
name: dry-core
---

Allows you to cache call results that are solely determined by arguments.

```ruby
require "dry/core"

class Foo
  extend Dry::Core::Cache

  attr_reader :source

  def initialize(source)
    @source = source
  end

  def heavy_computation(arg1, arg2)
    fetch_or_store(source, arg1, arg2) { source ^ arg1 ^ arg2 }
  end
end
```

### Note

Beware Proc instance hashes are not equal, i.e. `-> { 1 }.hash != -> { 1 }.hash`.
This means you shouldn't pass Procs in args unless you're sure they are always the same instances, otherwise you introduce a memory leak
