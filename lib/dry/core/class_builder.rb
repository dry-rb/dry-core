module Dry
  module Core
    # Class for generating more classes
    class ClassBuilder
      attr_reader :name
      attr_reader :parent

      def initialize(name: , parent: Object)
        @name = name
        @parent = parent
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
        klass = Class.new(parent)
        name = self.name

        klass.singleton_class.class_eval do
          define_method(:name) { name }
          alias_method :inspect, :name
          alias_method :to_str, :name
          alias_method :to_s, :name
        end

        yield(klass) if block_given?

        klass
      end
    end
  end
end
