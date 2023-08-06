---
title: Deprecations
layout: gem-single
name: dry-core
---

To deprecate ruby methods you need to extend the `Dry::Core::Deprecations` module with a tag that will be displayed in the output. For example:

```ruby
require "dry/core"

class Foo
  extend Dry::Core::Deprecations[:tag]

  def self.old_class_api; end
  def self.new_class_api; end

  deprecate_class_method :old_class_api, :new_class_api

  def old_api; end
  def new_api; end

  deprecate :old_api, :new_api
end

Foo.old_class_api
# => [tag] Foo.old_class_api is deprecated and will be removed in the next major version
# => Please use Foo.new_class_api instead.
# => file.rb:9:in `<class:Foo>'

Foo.new.old_api
# => [tag] Foo#old_api is deprecated and will be removed in the next major version
# => Please use Foo#new_api instead.
# => file.rb:14:in `<class:Foo>'
```
