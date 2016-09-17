require 'dry/core/constants'

RSpec.describe Dry::Core::Constants do
  before do
    class ClassWithConstants
      include Dry::Core::Constants

      def empty_array
        EMPTY_ARRAY
      end

      def empty_hash
        EMPTY_HASH
      end

      def empty_set
        EMPTY_SET
      end

      def empty_string
        EMPTY_STRING
      end

      def empty_opts
        EMPTY_OPTS
      end

      def undefined
        Undefined
      end
    end
  end

  after do
    Object.send(:remove_const, :ClassWithConstants)
  end

  subject { ClassWithConstants.new }

  it 'makes constants available in your class' do
    expect(subject.empty_array).to be Dry::Core::Constants::EMPTY_ARRAY
    expect(subject.empty_array).to eql([])

    expect(subject.empty_hash).to be Dry::Core::Constants::EMPTY_HASH
    expect(subject.empty_hash).to eql({})

    expect(subject.empty_set).to be Dry::Core::Constants::EMPTY_SET
    expect(subject.empty_set).to eql(Set.new)

    expect(subject.empty_string).to be Dry::Core::Constants::EMPTY_STRING
    expect(subject.empty_string).to eql('')

    expect(subject.empty_opts).to be Dry::Core::Constants::EMPTY_OPTS
    expect(subject.empty_opts).to eql({})

    expect(subject.undefined).to be Dry::Core::Constants::Undefined
    expect(subject.undefined.to_s).to eql('Undefined')
    expect(subject.undefined.inspect).to eql('Undefined')
  end
end
