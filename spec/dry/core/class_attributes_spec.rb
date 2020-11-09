# frozen_string_literal: true

require 'dry/core/class_attributes'
require 'dry-types'

RSpec.describe 'Class Macros' do
  before do
    module Test
      class MyClass
        extend Dry::Core::ClassAttributes

        defines :one, :two, :three

        one 1
        two 2
        three 3
      end

      class OtherClass < Test::MyClass
        two 'two'
        three nil
      end
    end
  end

  it 'defines accessor like methods on the class and subclasses' do
    %i(one two three).each do |method_name|
      expect(Test::MyClass).to respond_to(method_name)
      expect(Test::OtherClass).to respond_to(method_name)
    end
  end

  it 'allows storage of values on the class' do
    expect(Test::MyClass.one).to eq(1)
    expect(Test::MyClass.two).to eq(2)
    expect(Test::MyClass.three).to eq(3)
  end

  it 'allows overwriting of inherited values with nil' do
    expect(Test::OtherClass.three).to eq(nil)
  end

  context 'type option' do
    let(:klass) do
      module Test
        class NewClass
          extend Dry::Core::ClassAttributes
        end
      end

      Test::NewClass
    end

    context 'using classes' do
      before do
        klass.defines :one, type: String
      end

      it 'allows to pass type option' do
        klass.one '1'
        expect(Test::NewClass.one).to eq '1'
      end

      it 'raises InvalidClassAttributeValue when invalid value is pass' do
        expect {
          klass.one 1
        }.to raise_error(
          Dry::Core::InvalidClassAttributeValue,
          'Value 1 is invalid for class attribute :one'
        )
      end
    end

    context 'using dry-types' do
      before do
        module Test
          class Types
            include Dry::Types()
          end
        end

        klass.defines :one, type: Test::Types::String
      end

      it 'allows to pass type option' do
        klass.one '1'
        expect(Test::NewClass.one).to eq '1'
      end

      it 'raises InvalidClassAttributeValue when invalid value is pass' do
        expect {
          klass.one 1
        }.to raise_error(Dry::Core::InvalidClassAttributeValue)
      end
    end

    context 'using coercible dry-types' do
      before do
        module Test
          class Types
            include Dry::Types()
          end
        end

        klass.defines :one, type: Test::Types::Coercible::String
      end

      it 'allows to pass type option' do
        klass.one '1'
        expect(Test::NewClass.one).to eq '1'
      end

      it 'coerces value based on type option' do
        klass.one 1
        expect(Test::NewClass.one).to eq '1'
      end
    end
  end

  it 'allows inheritance of values' do
    expect(Test::OtherClass.one).to eq(1)
  end

  it 'allows overwriting of inherited values' do
    expect(Test::OtherClass.two).to eq('two')
  end

  it 'copies values from the parent before running hooks' do
    subclass_value = nil

    module_with_hook = Module.new do
      define_method(:inherited) do |klass|
        super(klass)

        subclass_value = klass.one
      end
    end

    base_class = Class.new do
      extend Dry::Core::ClassAttributes
      extend module_with_hook

      defines :one
      one 1
    end

    Class.new(base_class)

    expect(subclass_value).to be 1
  end

  it 'works with private setters/getters and inheritance' do
    base_class = Class.new do
      extend Dry::Core::ClassAttributes

      defines :one
      class << self; private :one; end
      one 1
    end

    spec = self

    child = Class.new(base_class) do |chld|
      spec.instance_exec { expect(chld.send(:one)).to spec.eql(1) }

      one 'one'
    end

    expect(child.send(:one)).to eql('one')
  end
end
