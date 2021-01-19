# frozen_string_literal: true

require_relative "constants"

module Dry
  module Core
    module Memoizable
      module KeywordArguments
        if respond_to?(:ruby2_keywords, true)
          def method_added(method)
            ruby2_keywords(method)
          end
        end
      end

      module ClassInterface
        include Core::Constants
        extend KeywordArguments

        def memoize(*names)
          prepend(Memoizer.new(self, names))
        end

        def new(*)
          obj = super
          obj.instance_eval { @__memoized__ = EMPTY_HASH.dup }
          obj
        end
      end

      def self.included(klass)
        super
        klass.extend(ClassInterface)
      end

      # @api private
      class Memoizer < Module
        include KeywordArguments

        # @api private
        def initialize(klass, names)
          names.each do |name|
            define_method(name) do |*args, &block|
              id = [name, args, block]

              if @__memoized__.key?(id)
                next @__memoized__[id]
              end

              if !defined?(super) && !respond_to_missing?(name, true)
                raise NoMethodError, "Undefined memoized method [#{klass}##{name}]"
              end

              @__memoized__[id] = super(*args, &block)
            end
          end
        end
      end
    end
  end
end
