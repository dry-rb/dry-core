# v0.4.0 2017-11-02

### Added

* Added the `:type` option to class attributes, you can now restrict attribute values with a type. You can either use plain ruby types (`Integer`, `String`, etc) or `dry-types` (GustavoCaso)

  ```ruby
    class Foo
      extend Dry::Core::ClassAttributes

      defines :ruby_attr, type: Integer
      defines :dry_attr, type: Dry::Types['strict.int']
    end
  ```

[Compare v0.3.4...v0.4.0](https://github.com/dry-rb/dry-core/compare/v0.3.4...v0.4.0)

# v0.3.4 2017-09-29

### Fixed

* `Deprecations` output is set to `$stderr` by default now (solnic)

[Compare v0.3.3...v0.3.4](https://github.com/dry-rb/dry-core/compare/v0.3.3...v0.3.4)

# v0.3.3 2017-08-31

### Fixed

* The Deprecations module now shows the right caller line (flash-gordon)

[Compare v0.3.2...v0.3.3](https://github.com/dry-rb/dry-core/compare/v0.3.2...v0.3.3)

# v0.3.2 2017-08-31

### Added

* Accept an existing logger object in `Dry::Core::Deprecations.set_logger!` (flash-gordon)

[Compare v0.3.1...v0.3.2](https://github.com/dry-rb/dry-core/compare/v0.3.1...v0.3.2)

# v0.3.1 2017-05-27

### Added

* Support for building classes within an existing namespace (flash-gordon)

[Compare v0.3.0...v0.3.1](https://github.com/dry-rb/dry-core/compare/v0.3.0...v0.3.1)

# v0.3.0 2017-05-05

### Changed

* Class attributes are initialized _before_ running the `inherited` hook. It's slightly more convenient behavior and it's very unlikely anyone will be affected by this, but technically this is a breaking change (flash-gordon)

[Compare v0.2.4...v0.3.0](https://github.com/dry-rb/dry-core/compare/v0.2.4...v0.3.0)

# v0.2.4 2017-01-26

### Fixed

* Do not require deprecated method to be defined (flash-gordon)

[Compare v0.2.3...v0.2.4](https://github.com/dry-rb/dry-core/compare/v0.2.3...v0.2.4)

# v0.2.3 2016-12-30

### Fixed

* Fix warnings on using uninitialized class attributes (flash-gordon)

[Compare v0.2.2...v0.2.3](https://github.com/dry-rb/dry-core/compare/v0.2.2...v0.2.3)

# v0.2.2 2016-12-30

### Added

* `ClassAttributes` which provides `defines` method for defining get-or-set methods (flash-gordon)

[Compare v0.2.1...v0.2.2](https://github.com/dry-rb/dry-core/compare/v0.2.1...v0.2.2)

# v0.2.1 2016-11-18

### Added

* `Constants` are now available in nested scopes (flash-gordon)

[Compare v0.2.0...v0.2.1](https://github.com/dry-rb/dry-core/compare/v0.2.0...v0.2.1)

# v0.2.0 2016-11-01

[Compare v0.1.0...v0.2.0](https://github.com/dry-rb/dry-core/compare/v0.1.0...v0.2.0)

# v0.1.0 2016-09-17

Initial release
