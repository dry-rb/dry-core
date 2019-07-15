# frozen_string_literal: true

require 'dry/core/memoizable'

RSpec.describe Dry::Core::Memoizable, '.memoize' do
  subject(:object) do
    Class.new do
      include Dry::Core::Memoizable

      attr_reader :falsey_call_count

      def initialize
        @falsey_call_count = 0
      end

      def foo
        ['a', 'ab', 'abc'].max
      end
      memoize :foo

      def bar(arg)
        { a: '1', b: '2' }
      end
      memoize :bar

      def falsey
        @falsey_call_count += 1
        false
      end
      memoize :falsey
    end.new
  end

  it 'memoizes method return value' do
    expect(object.foo).to be(object.foo)
  end

  it 'memoizes method return value with an arg' do
    expect(object.bar(:a)).to be(object.bar(:a))
    expect(object.bar(:b)).to be(object.bar(:b))
  end

  it 'memoizes falsey values' do
    expect(object.falsey).to be(object.falsey)
    expect(object.falsey_call_count).to eq 1
  end

  context 'frozen object' do
    before { object.freeze }

    it 'works' do
      expect(object.foo).to be(object.foo)
    end
  end
end
