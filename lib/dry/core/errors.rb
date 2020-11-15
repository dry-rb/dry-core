# frozen_string_literal: true

module Dry
  module Core
    class InvalidClassAttributeValue < StandardError
      def initialize(name, value)
        super(
          "Value #{value.inspect} is invalid for class attribute #{name.inspect}"
        )
      end
    end

    class InvalidCoerceOption < StandardError
      def initialize(name)
        super(
          "Coerce option for #{name.inspect} class attribute is not callable"
        )
      end
    end
  end
end
