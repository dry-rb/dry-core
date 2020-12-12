# frozen_string_literal: true

require "dry/core/cache"

RSpec.describe Dry::Core::Cache do
  shared_examples_for "class with cache" do
    describe "#fetch_or_store" do
      it "stores and fetches a value" do
        args = [1, 2, 3]
        value = "foo"

        expect(klass.fetch_or_store(*args) { value }).to be(value)
        expect(klass.fetch_or_store(*args)).to be(value)

        object = klass.new

        expect(object.fetch_or_store(*args) { value }).to be(value)
        expect(object.fetch_or_store(*args)).to be(value)
      end
    end
  end

  let(:base_class) do
    Class.new do
      extend Dry::Core::Cache
    end
  end

  let(:child_class) do
    Class.new(base_class)
  end

  it_behaves_like "class with cache" do
    let(:klass) { base_class }
  end

  context "inheritance" do
    it_behaves_like "class with cache" do
      let(:klass) { child_class }
    end

    it "uses the same values in child and parent" do
      value = Object.new
      expect(base_class.fetch_or_store(1, 2) { value }).to be(value)
      expect(base_class.fetch_or_store(1, 2) { fail }).to be(value)

      expect(child_class.fetch_or_store(1, 2) { fail }).to be(value)
      expect(child_class.new.fetch_or_store(1, 2) { fail }).to be(value)
    end

    it "does not depend on fetch order" do
      value = Object.new
      expect(child_class.fetch_or_store(1, 2) { value }).to be(value)
      expect(child_class.fetch_or_store(1, 2) { fail }).to be(value)

      expect(base_class.fetch_or_store(1, 2) { fail }).to be(value)
      expect(base_class.new.fetch_or_store(1, 2) { fail }).to be(value)
    end
  end
end
