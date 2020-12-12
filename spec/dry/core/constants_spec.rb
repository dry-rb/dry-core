# frozen_string_literal: true

require "dry/core/constants"

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

  it "makes constants available in your class" do
    expect(subject.empty_array).to be Dry::Core::Constants::EMPTY_ARRAY
    expect(subject.empty_array).to eql([])

    expect(subject.empty_hash).to be Dry::Core::Constants::EMPTY_HASH
    expect(subject.empty_hash).to eql({})

    expect(subject.empty_set).to be Dry::Core::Constants::EMPTY_SET
    expect(subject.empty_set).to eql(Set.new)

    expect(subject.empty_string).to be Dry::Core::Constants::EMPTY_STRING
    expect(subject.empty_string).to eql("")

    expect(subject.empty_opts).to be Dry::Core::Constants::EMPTY_OPTS
    expect(subject.empty_opts).to eql({})

    expect(subject.undefined).to be Dry::Core::Constants::Undefined
  end

  describe "nested" do
    before do
      class ClassWithConstants
        class Nested
          def empty_array
            EMPTY_ARRAY
          end
        end
      end
    end

    subject { ClassWithConstants::Nested.new }

    example "constants available in lexical scope" do
      expect(subject.empty_array).to be Dry::Core::Constants::EMPTY_ARRAY
    end
  end

  describe "Undefined" do
    subject(:undefined) { Dry::Core::Constants::Undefined }

    describe ".inspect" do
      it 'returns "Undefined"' do
        expect(subject.inspect).to eql("Undefined")
      end
    end

    describe ".to_s" do
      it 'returns "Undefined"' do
        expect(subject.to_s).to eql("Undefined")
      end
    end

    describe ".default" do
      it "returns the first arg if it's not Undefined" do
        expect(subject.default(:first, :second)).to eql(:first)
      end

      it "returns the second arg if the first one is Undefined" do
        expect(subject.default(subject, :second)).to eql(:second)
      end

      it "yields a block" do
        expect(subject.default(subject) { :second }).to eql(:second)
      end
    end

    describe ".map" do
      it "maps non-undefined value" do
        expect(subject.map("foo", &:to_sym)).to be(:foo)
        expect(subject.map(subject, &:to_sym)).to be(subject)
      end
    end

    describe ".dup" do
      subject { undefined.dup }

      it { is_expected.to be(undefined) }
    end

    describe ".clone" do
      subject { undefined.clone }

      it { is_expected.to be(undefined) }
    end

    describe ".coalesce" do
      it "returns first non-undefined value in a list" do
        expect(undefined.coalesce(1, 2)).to be(1)
        expect(undefined.coalesce(undefined, 1, 2)).to be(1)
        expect(undefined.coalesce(undefined, undefined, 1, 2)).to be(1)
        expect(undefined.coalesce(undefined, undefined)).to be(undefined)
        expect(undefined.coalesce(nil)).to be(nil)
        expect(undefined.coalesce(undefined, nil)).to be(nil)
        expect(undefined.coalesce(undefined, nil, false)).to be(nil)
        expect(undefined.coalesce(undefined, false, nil)).to be(false)
      end
    end
  end
end
