module Dry
  module Core
    # Class for generating more classes
    class ClassBuilder
      attr_reader :name
      attr_reader :parent
      attr_reader :namespace

      def initialize(name:, parent: nil, namespace: nil)
        @name = name
        @namespace = namespace
        @parent = parent || Object
      end

      # Generate a class based on options
      #
      # @example
      #   builder = Dry::Core::ClassBuilder.new(name: 'MyClass')
      #
      #   klass = builder.call
      #   klass.name # => "MyClass"
      #
      # @return [Class]
      def call
        klass = if namespace
                  create_named
                else
                  create_anonymous
                end

        yield(klass) if block_given?

        klass
      end

      private

      # @api private
      def create_base(namespace, name, parent)
        if namespace.const_defined?(name)
          namespace.const_get(name)
        else
          klass = Class.new(parent || Object)
          namespace.const_set(name, klass)
          klass
        end
      end

      # @api private
      def create_anonymous
        klass = Class.new(parent)
        name = self.name

        klass.singleton_class.class_eval do
          define_method(:name) { name }
          alias_method :inspect, :name
          alias_method :to_s, :name
        end

        klass
      end

      # @api private
      def create_named
        name = self.name
        base = create_base(namespace, name, parent)
        klass = Class.new(base)

        namespace.module_eval do
          remove_const(name)
          const_set(name, klass)
          remove_const(name)
          const_set(name, base)
        end

        klass
      end
    end
  end
end
