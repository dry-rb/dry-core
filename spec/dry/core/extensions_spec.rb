require 'dry/core/extensions'

RSpec.describe Dry::Core::Extensions do
  subject do
    Class.new do
      extend Dry::Core::Extensions

      def self.define_foo
        define_method(:foo) {}
      end
    end
  end

  it 'allows to register and load extensions' do
    foo = false
    bar = false

    subject.register_extension(:foo) { foo = true }
    subject.register_extension(:bar) { bar = true }

    subject.load_extensions(:foo, :bar)

    expect(foo).to be true
    expect(bar).to be true
  end

  it 'allows extending with instance methods' do
    subject.register_extension(:foo) { def foo; end }

    subject.load_extensions(:foo)

    expect(subject.new).to respond_to :foo
  end

  it 'allows extending with class methods' do
    subject.register_extension(:foo) { def self.foo; end }

    subject.load_extensions(:foo)

    expect(subject).to respond_to :foo
  end

  it 'allows extending with execution of class methods' do
    subject.register_extension(:foo) { define_foo }

    subject.load_extensions(:foo)

    expect(subject.new).to respond_to :foo
  end

  it 'swallows double loading' do
    cnt = 0

    subject.register_extension(:foo) { cnt += 1 }
    subject.load_extensions(:foo)
    subject.load_extensions(:foo)

    expect(cnt).to be 1
  end

  it 'raise ArgumentError on loading unknown extension' do
    subject.register_extension(:foo) { fail }
    expect {
      subject.load_extensions(:bar)
    }.to raise_error ArgumentError, 'Unknown extension: :bar'
  end

  it 'allows to query if an extension is available' do
    subject.register_extension(:foo) { }
    expect(subject.available_extension?(:foo)).to be true
    expect(subject.available_extension?(:bar)).to be false
  end
end
