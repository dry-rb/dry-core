# frozen_string_literal: true

require_relative "constants"

module Dry
  module Core
    module Memoizable
      module ClassInterface
        include Core::Constants

        def memoize(*names)
          prepend(Memoizer.new(names))
        end

        def new(*)
          obj = super
          obj.instance_eval { @__memoized__ = EMPTY_HASH.dup }
          obj
        end

        if respond_to?(:ruby2_keywords, true)
          ruby2_keywords(:new)
        end
      end

      def self.included(klass)
        super
        klass.extend(ClassInterface)
      end

      attr_reader :__memoized__

      # @api private
      class Memoizer < Module
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

            if respond_to?(:ruby2_keywords, true)
              ruby2_keywords(name)
            end
          end
        end
      end
    end
  end
end
