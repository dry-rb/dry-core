# frozen_string_literal: true

RSpec.describe Dry::Core::Container do
  let(:klass) { Dry::Core::Container }
  let(:container) { klass.new }

  it_behaves_like "a container"

  describe "inheritance" do
    it "sets up a container for a child class" do
      parent = Class.new { extend Dry::Core::Container::Mixin }
      child = Class.new(parent)

      parent.register(:foo, Object.new)
      child.register(:foo, Object.new)

      expect(parent[:foo]).to_not be(child[:foo])
    end
  end
end
