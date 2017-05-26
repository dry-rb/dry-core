require 'dry/core/constants'

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
      #   class MyClass
      #     extend Dry::Core::ClassAttributes
      #
      #     defines :one, :two
      #
      #     one 1
      #     two 2
      #   end
      #
      #   class OtherClass < MyClass
      #     two 'two'
      #   end
      #
      #   MyClass.one # => 1
      #   MyClass.two # => 2
      #
      #   OtherClass.one # => 1
      #   OtherClass.two # => 'two'
      def defines(*args)
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
