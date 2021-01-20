# frozen_string_literal: true

require "dry/core/memoizable"

RSpec.describe Dry::Core::Memoizable, ".memoize" do
  describe Object do
    it_behaves_like "a memoizable class" do
      context "frozen object" do
        before { object.freeze }

        it "works" do
          expect(object.foo).to be(object.foo)
        end
      end
    end
  end

  describe BasicObject do
    it_behaves_like "a memoizable class"
  end

  describe Class.new(Object) do
    it_behaves_like "a memoizable class"
  end

  describe Class.new(BasicObject) do
    it_behaves_like "a memoizable class"
  end
end
