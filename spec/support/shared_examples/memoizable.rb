# frozen_string_literal: true

RSpec.shared_examples "a memoizable class" do
  subject(:object) do
    Class.new(described_class) do
      include Dry::Core::Memoizable

      attr_reader :falsey_call_count

      def initialize
        super
        @falsey_call_count = 0
      end

      def foo
        %w[a ab abc].max
      end
      memoize :foo

      def bar(_arg)
        {a: "1", b: "2"}
      end
      memoize :bar

      def bar_with_block(&block)
        block.call
      end
      memoize :bar_with_block

      def bar_with_kwargs(*args, **kwargs)
        {args: args, kwargs: kwargs}
      end
      memoize :bar_with_kwargs

      def falsey
        @falsey_call_count += 1
        false
      end
      memoize :falsey
    end.new
  end

  it "memoizes method return value" do
    expect(object.foo).to be(object.foo)
  end

  it "memoizes method return value with an arg" do
    expect(object.bar(:a)).to be(object.bar(:a))
    expect(object.bar(:b)).to be(object.bar(:b))
  end

  it "memoizes falsey values" do
    expect(object.falsey).to be(object.falsey)
    expect(object.falsey_call_count).to eq 1
  end

  describe "keyword arguments" do
    let(:kwargs) { {key: "value"} }
    let(:args) { [1] }

    it "memoizes keyword arguments" do
      expect(object.bar_with_kwargs(*args, **kwargs)).to eq({args: args, kwargs: kwargs})
    end
  end

  describe "with block" do
    let(:spy1) { double(:spy1) }
    let(:spy2) { double(:spy2) }
    let(:block1) { -> { spy1.call } }
    let(:block2) { -> { spy2.call } }
    let(:returns1) { :return_value1 }
    let(:returns2) { :return_value2 }

    before do
      expect(spy1).to receive(:call).and_return(returns1).once
      expect(spy2).to receive(:call).and_return(returns2).once
    end

    let(:results1) do
      2.times.map do
        object.bar_with_block(&block1)
      end
    end

    let(:results2) do
      2.times.map do
        object.bar_with_block(&block2)
      end
    end

    let(:returns) do
      [returns1, returns2] * 2
    end

    subject do
      results1 + results2
    end

    it { is_expected.to match_array(returns) }
  end
end

RSpec.shared_examples "a memoized method" do
  let(:old_meth) { described_class.class.instance_method(new_meth.name) }

  describe "new != old" do
    subject { new_meth }
    it { is_expected.not_to eq(old_meth) }
  end

  describe "new.arity == old.arity" do
    subject { new_meth.arity }
    it { is_expected.to eq(old_meth.arity) }
  end

  describe "new.name == old.name" do
    subject { new_meth.name }
    it { is_expected.to eq(old_meth.name) }
  end
end
