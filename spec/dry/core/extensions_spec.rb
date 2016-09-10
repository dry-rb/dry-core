require 'dry/core/extensions'

RSpec.describe Dry::Core::Extensions do
  subject do
    Class.new do
      extend Dry::Core::Extensions
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

  it 'swallows double loading' do
    cnt = 0

    subject.register_extension(:foo) { cnt += 1 }
    subject.load_extensions(:foo)
    subject.load_extensions(:foo)

    expect(cnt).to be 1
  end
end
