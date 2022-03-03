# frozen_string_literal: true

require "dry/core/basic_object"
require "pp"

class ExternalTestClass
end

class TestClass < Dry::Core::BasicObject
  class InternalTestClass
  end

  def internal
    InternalTestClass
  end

  def external
    ExternalTestClass
  end
end

class InspectTestClass < TestClass
  def __inspect
    " hello"
  end
end

RSpec.describe Dry::Core::BasicObject do
  describe ".const_missing" do
    subject { TestClass.new }

    it "lookups constants at the top-level namespace" do
      expect(subject.internal).to eq(TestClass::InternalTestClass)
      expect(subject.external).to eq(ExternalTestClass)
    end
  end

  describe "#respond_to_missing?" do
    it "raises an exception if respond_to? method is not implemented" do
      expect { TestClass.new.respond_to?(:no_existing_method) }
        .to raise_error(NotImplementedError)
    end

    it "returns true given respond_to? method was implemented" do
      TestCase = Class.new(TestClass) do
        def respond_to?(_method_name, _include_all = false)
          true
        end
      end

      expect(TestCase.new).to respond_to(:no_existing_method)
    end
  end

  describe "#class" do
    it "returns TestClass" do
      expect(TestClass.new.class).to eq TestClass
    end
  end

  describe "#inspect" do
    it "returns object inspection" do
      actual = TestClass.new.inspect
      expect(actual).to match(/\A#<TestClass:\w+>\z/)
    end

    it "returns custom object inspection" do
      actual = InspectTestClass.new.inspect
      expect(actual).to match(/\A#<InspectTestClass:\w+\shello>\z/)
    end
  end

  describe "#pretty_print" do
    # See https://github.com/hanami/hanami/issues/629
    it "is pretty printable" do
      expect { pp TestClass.new }.to output(/TestClass/).to_stdout
    end

    # See https://github.com/hanami/utils/issues/234
    it "outputs the inspection to the given printer" do
      printer = PP.new
      subject = TestClass.new
      subject.pretty_print(printer)

      expect(printer.output).to match(/\A#<TestClass:\w+>\z/)
    end
  end

  describe "#instance_of?" do
    subject { TestClass.new }

    context "when object is instance of the given class" do
      it "returns true" do
        expect(subject.instance_of?(TestClass)).to be(true)
      end
    end

    context "when object is not instance of the given class" do
      it "returns false" do
        expect(subject.instance_of?(::String)).to be(false)
      end
    end

    context "when given argument is not a class or module" do
      it "raises error" do
        expect { subject.instance_of?("foo") }.to raise_error(TypeError)
      end
    end
  end

  describe "#is_a?" do
    subject { TestClass.new }
    let(:test_class) { TestClass }

    context "when object is instance of the given class" do
      it "returns true" do
        expect(subject.is_a?(TestClass)).to be(true)
      end
    end

    context "when object is not instance of the given class" do
      it "returns false" do
        expect(subject.is_a?(::String)).to be(false)
      end
    end

    context "when given argument is not a class or module" do
      it "raises error" do
        expect { subject.is_a?("foo") }.to raise_error(TypeError)
      end
    end

    context "when object is instance of the subclass" do
      subject { Class.new(TestClass).new }

      it "returns true" do
        expect(subject.is_a?(TestClass)).to be(true)
      end
    end

    context "when object has given module included" do
      subject do
        m = mod
        Class.new { include m }.new
      end

      let(:mod) { Module.new }

      it "returns true" do
        expect(subject.is_a?(mod)).to be(true)
      end
    end
  end

  # rubocop:disable Style/ClassCheck
  describe "#kind_of?" do
    context "when object is instance of the given class" do
      subject { TestClass.new }

      it "returns true" do
        expect(subject.kind_of?(TestClass)).to be(true)
      end
    end

    context "when object is instance of the subclass" do
      subject { Class.new(TestClass).new }

      it "returns true" do
        expect(subject.kind_of?(TestClass)).to be(true)
      end
    end

    context "when object is not instance of the given class" do
      it "returns false" do
        expect(subject.kind_of?(::String)).to be(false)
      end
    end

    context "when given argument is not a class or module" do
      it "raises error" do
        expect { subject.kind_of?("foo") }.to raise_error(TypeError)
      end
    end

    context "when object has given module included" do
      subject do
        m = mod
        Class.new { include m }.new
      end

      let(:mod) { Module.new }

      it "returns true" do
        expect(subject.kind_of?(mod)).to be(true)
      end
    end
  end
  # rubocop:enable Style/ClassCheck
end
