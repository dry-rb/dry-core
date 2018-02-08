require 'set'

module Dry
  module Core
    # A list of constants you can use to avoid memory allocations or identity checks.
    #
    # @example Just include this module to your class or module
    #   class Foo
    #     def call(value = EMPTY_ARRAY)
    #        value.map(&:to_s)
    #     end
    #   end
    #
    # @api public
    module Constants
      # An empty array
      EMPTY_ARRAY = [].freeze
      # An empty hash
      EMPTY_HASH = {}.freeze
      # An empty list of options
      EMPTY_OPTS = {}.freeze
      # An empty set
      EMPTY_SET = Set.new.freeze
      # An empty string
      EMPTY_STRING = ''.freeze

      # A special value you can use as a default to know if no arguments
      # were passed to you method
      #
      # @example
      #   def method(value = Undefined)
      #     if value == Undefined
      #       puts 'no args'
      #     else
      #       puts value
      #     end
      #   end
      Undefined = Object.new.tap do |undefined|
        def undefined.to_s
          'Undefined'
        end

        def undefined.inspect
          'Undefined'
        end

        # Pick a value, if the first argument is not Undefined, return it back,
        # otherwise return the second arg or yield the block.
        #
        # @example
        #  def method(val = Undefined)
        #    1 + Undefined.default(val, 2)
        #  end
        #
        def undefined.default(x, y = self)
          if x.equal?(self)
            if y.equal?(self)
              yield
            else
              y
            end
          else
            x
          end
        end
      end.freeze

      def self.included(base)
        super

        constants.each do |const_name|
          base.const_set(const_name, const_get(const_name))
        end
      end
    end
  end
end
