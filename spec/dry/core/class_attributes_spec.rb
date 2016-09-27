require 'dry/core/class_attributes'

RSpec.describe 'Class Macros' do
  class MyClass
    extend Dry::Core::ClassAttributes

    defines :one, :two, :three

    one 1
    two 2
    three 3
  end

  class OtherClass < MyClass
    two 'two'
    three nil
  end

  after(:all) do
    %i(MyClass OtherClass).each { |k| Object.send(:remove_const, k) }
  end

  it 'defines accessor like methods on the class and subclasses' do
    %i(one two three).each do |method_name|
      expect(MyClass).to respond_to(method_name)
      expect(OtherClass).to respond_to(method_name)
    end
  end

  it 'allows storage of values on the class' do
    expect(MyClass.one).to eq(1)
    expect(MyClass.two).to eq(2)
    expect(MyClass.three).to eq(3)
  end

  it 'allows overwriting of inherited values with nil' do
    expect(OtherClass.three).to eq(nil)
  end

  it 'allows inheritance of values' do
    expect(OtherClass.one).to eq(1)
  end

  it 'allows overwriting of inherited values' do
    expect(OtherClass.two).to eq('two')
  end
end
