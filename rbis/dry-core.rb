# typed: strong
module Dry
end

module Dry::Core
end

module Dry::Core::Constants
  def self.included(base); end
end

class Dry::Core::ClassBuilder
  def call; end
  def create_anonymous; end
  def create_base(namespace, name, parent); end
  def create_named; end
  def initialize(name:, parent: nil, namespace: nil); end
  def name; end
  def namespace; end
  def parent; end
end

class Dry::Core::ClassBuilder::ParentClassMismatch < TypeError
end

module Dry::Core::Extensions
  def available_extension?(name); end
  def load_extensions(*extensions); end
  def register_extension(name, &block); end
  def self.extended(obj); end
end

class Dry::Core::InvalidClassAttributeValue < StandardError
  def initialize(name, value); end
end

module Dry::Core::ClassAttributes
  include Dry::Core::Constants

  sig { params(args: T::Array[Symbol], type: T.untyped).void }
  def defines(*args, type: nil); end
end

module Dry::Core::Deprecations
  sig { params(args: T::Array[Symbol], type: T.untyped).void }
  def self.warn(msg, tag: nil); end

  def self.[](tag); end
  def self.announce(name, msg, tag: nil); end
  def self.deprecated_name_message(old, new = nil, msg = nil); end
  def self.deprecation_message(name, msg); end
  def self.logger(output = nil); end
  def self.set_logger!(output = nil); end
end

class Dry::Core::Deprecations::Tagged < Module
  def extended(base); end
  def initialize(tag); end
end

module Dry::Core::Deprecations::Interface
  def deprecate(old_name, new_name = nil, message: nil); end
  def deprecate_class_method(old_name, new_name = nil, message: nil); end
  def deprecate_constant(constant_name, message: nil); end
  def deprecation_tag(tag = nil); end
  def warn(msg); end
end

module Dry::Core::Inflector
  def self.camelize(input); end
  def self.classify(input); end
  def self.constantize(input); end
  def self.demodulize(input); end
  def self.detect_backend; end
  def self.inflector; end
  def self.pluralize(input); end
  def self.realize_backend(path, backend_factory); end
  def self.select_backend(name = nil); end
  def self.singularize(input); end
  def self.underscore(input); end
end

module Dry::Core::Cache
  sig { returns(Concurrent::Map) }
  def cache; end

  sig do
    params(args: Array, block: T.proc.void).returns(::T.untyped)
  end
  def fetch_or_store(*args, &block); end

  sig { params(klass: Class).void }
  def inherited(klass); end

  sig { params(klass: Class).void }
  def self.extended(klass); end
end

module Dry::Core::Cache::Methods
  sig do
    params(args: Array, block: T.proc.void).returns(::T.untyped)
  end
  def fetch_or_store(*args, &block); end
end
