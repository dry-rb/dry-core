# frozen_string_literal: true

RSpec.describe "legacy Dry::Equalizer name" do
  it "behaves the same as when using Dry::Core::Equalizer" do
    klass = Class.new {
      attr_reader :name

      def initialize(name)
        @name = name
      end
    }
    allow(klass).to receive_messages(name: nil, inspect: "User") # specify the class #inspect method
    klass.include Dry::Equalizer(:name)

    instance = klass.new("Jane")
    other = instance.dup

    expect(instance).to eql(other)
  end
end
