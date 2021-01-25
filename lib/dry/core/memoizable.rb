# frozen_string_literal: true

module Dry
  module Core
    module Memoizable
      MEMOIZED_HASH = {}.freeze

      module ClassInterface
        module Base
          def memoize(*names)
            prepend(Memoizer.new(self, names))
          end
        end

        module BasicObject
          include Base

          def new(*)
            obj = super
            obj.instance_eval { @__memoized__ = MEMOIZED_HASH.dup }
            obj
          end
        end

        module Object
          include Base

          def new(*)
            obj = super
            obj.instance_variable_set(:'@__memoized__', MEMOIZED_HASH.dup)
            obj
          end
        end
      end

      def self.included(klass)
        super

        if klass <= Object
          klass.extend(ClassInterface::Object)
        else
          klass.extend(ClassInterface::BasicObject)
        end
      end

      attr_reader :__memoized__

      # @api private
      class Memoizer < Module
        attr_reader :klass
        attr_reader :names

        # @api private
        def initialize(klass, names)
          @names = names
          @klass = klass
          define_memoizable_names!
        end

        private

        # @api private
        def define_memoizable_names!
          names.each do |name|
            meth = klass.instance_method(name)

            if meth.parameters.size > 0
              define_method(name) do |*args, &block|
                name_with_args = :"#{name}_#{args.hash}_#{block.hash}"

                if __memoized__.key?(name_with_args)
                  __memoized__[name_with_args]
                else
                  __memoized__[name_with_args] = super(*args, &block)
                end
              end
            else
              define_method(name) do
                if __memoized__.key?(name)
                  __memoized__[name]
                else
                  __memoized__[name] = super()
                end
              end
            end
          end
        end
      end
    end
  end
end
