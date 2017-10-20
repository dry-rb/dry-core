require 'dry/core/constants'
require 'dry/core/errors'
require 'dry-types'

module Dry
  module Core
    # Internal support module for class-level settings
    #
    # @api public
    module ClassAttributes
      include Constants

      # Specify what attributes a class will use
      #
      # @example
      #  class ExtraClass
      #    extend Dry::Core::ClassAttributes
      #
      #    defines :hello
      #
      #    hello 'world'
      #  end
      #
      #   class MyClass
      #     extend Dry::Core::ClassAttributes
      #
      #     defines :one, :two, type: Dry::Types::Int
      #
      #     one 1
      #     two 2
      #   end
      #
      #   class OtherClass < MyClass
      #     two 3
      #   end
      #
      #   MyClass.one # => 1
      #   MyClass.two # => 2
      #
      #   OtherClass.one # => 1
      #   OtherClass.two # => 3
      def defines(*args, type: Dry::Types::Any)
        mod = Module.new do
          args.each do |name|
            define_method(name) do |value = Undefined|
              ivar = "@#{name}"

              if value == Undefined
                if instance_variable_defined?(ivar)
                  instance_variable_get(ivar)
                else
                  nil
                end
              else
                raise InvalidClassAttributeValue unless type.valid?(value)

                instance_variable_set(ivar, value)
              end
            end
          end

          define_method(:inherited) do |klass|
            args.each { |name| klass.public_send(name, send(name)) }

            super(klass)
          end
        end

        extend(mod)
      end
    end
  end
end
