# frozen_string_literal: true

require "concurrent/atomic/atomic_fixnum"
require "dry/core/memoizable"
require_relative "../../support/memoized"

RSpec.describe Dry::Core::Memoizable do
  describe ".memoize" do
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

  describe Memoized.new do
    let(:block) { -> {} }

    describe described_class.method(:test1) do
      it_behaves_like "a memoized method"

      it "does not raise an error" do
        2.times do
          described_class.call("a", kwarg1: "world", other: "test", &block)
        end
      end
    end

    describe described_class.method(:test2) do
      it_behaves_like "a memoized method"

      it "does not raise an error" do
        2.times { described_class.call("a", &block) }
      end
    end

    describe described_class.method(:test3) do
      it_behaves_like "a memoized method"

      it "does not raise an error" do
        2.times { described_class.call(&block) }
      end
    end

    describe described_class.method(:test4) do
      it_behaves_like "a memoized method"

      it "does not raise an error" do
        2.times { described_class.call }
      end
    end
  end

  describe ".new" do
    let(:args) { [double("arg")] }
    let(:kwargs) { {key: double("value")} }
    let(:block) { -> { double("block") } }

    let(:object) do
      Class.new do
        include Dry::Core::Memoizable
        attr_reader :args, :kwargs, :block

        def initialize(*args, **kwargs, &block)
          @args = args
          @kwargs = kwargs
          @block = block
        end
      end.new(*args, **kwargs, &block)
    end

    describe "#args" do
      subject { object.args }

      it { is_expected.to eq(args) }
    end

    describe "#kwargs" do
      subject { object.kwargs }

      it { is_expected.to eq(kwargs) }
    end

    describe "#block" do
      subject { object.block }

      it { is_expected.to eq(block) }
    end
  end

  context "test calls" do
    let(:klass) { Class.new.include(Dry::Core::Memoizable) }

    let(:instance) { klass.new }

    let(:counter) { Concurrent::AtomicFixnum.new }

    context "no args" do
      before do
        counter = self.counter
        klass.define_method(:meth) { counter.increment }
        klass.memoize(:meth)
      end

      it "gets called only once" do
        instance.meth
        instance.meth
        instance.meth

        expect(counter.value).to eql(1)
      end
    end

    context "pos arg" do
      before do
        counter = self.counter
        klass.define_method(:meth) { |req| counter.increment }
        klass.memoize(:meth)
      end

      it "memoizes results" do
        instance.meth(1)
        instance.meth(1)
        instance.meth(2)
        instance.meth(2)

        expect(counter.value).to eql(2)
      end
    end

    context "splat" do
      before do
        counter = self.counter
        klass.define_method(:meth) { |v, *args| counter.increment }
        klass.memoize(:meth)
      end

      it "memoizes results" do
        instance.meth(1)
        instance.meth(1)
        expect(counter.value).to eql(1)

        instance.meth(1, 2)
        instance.meth(1, 2)
        expect(counter.value).to eql(2)

        instance.meth(1, 2, 3)
        instance.meth(1, 2, 3)
        expect(counter.value).to eql(3)
      end
    end

    context "**kwargs" do
      before do
        counter = self.counter
        klass.define_method(:meth) { |foo:, **kwargs| counter.increment }
        klass.memoize(:meth)
      end

      it "memoizes results" do
        instance.meth(foo: 1)
        instance.meth(foo: 1)
        expect(counter.value).to eql(1)

        instance.meth(foo: 1, bar: 2)
        instance.meth(foo: 1, bar: 2)
        expect(counter.value).to eql(2)

        instance.meth(foo: 1, baz: 2)
        instance.meth(foo: 1, baz: 2)
        expect(counter.value).to eql(3)
      end
    end
  end
end
