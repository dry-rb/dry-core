module Dry
  module Core
    InvalidClassAttributeValue = Class.new(StandardError) do
      def initialize(name, value)
        super(
          "Value: #{value} is invalid for class attribute: #{name}"
        )
      end
    end
  end
end
