require 'set'

module Dry
  module Core
    module Constants
      EMPTY_ARRAY = [].freeze
      EMPTY_HASH = {}.freeze
      EMPTY_OPTS = {}.freeze
      EMPTY_SET = Set.new.freeze
      EMPTY_STRING = ''.freeze

      Undefined = Object.new.tap do |undefined|
        def undefined.to_s
          'Undefined'
        end

        def undefined.inspect
          'Undefined'
        end
      end.freeze
    end
  end
end
