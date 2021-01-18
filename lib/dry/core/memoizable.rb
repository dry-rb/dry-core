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
          prepend(Memoizer.new(names))
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

      attr_reader :__memoized__

      # @api private
      class Memoizer < Module
        include KeywordArguments

        # @api private
        def initialize(names)
          names.each do |name|
            define_method(name) do |*args, &block|
              id = [name, args, block]

              if __memoized__.key?(id)
                __memoized__[id]
              else
                __memoized__[id] = super(*args, &block)
              end
            end
          end
        end
      end
    end
  end
end
