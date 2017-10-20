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
    before do
      module Test
        class Types
          include Dry::Types.module
        end

        class NewClass
          extend Dry::Core::ClassAttributes

          defines :one, type: Test::Types::String

          one '1'
        end
      end
    end
    it 'allows to pass type option' do
      expect(Test::NewClass.one).to eq '1'
    end

    it 'raises InvalidClassAttributeValue when invalid value is pass' do
      expect{
        class InvalidNewClass
          extend Dry::Core::ClassAttributes

          defines :one, type: Test::Types::String

          one 1
        end
      }.to raise_error(Dry::Core::InvalidClassAttributeValue)
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
end
