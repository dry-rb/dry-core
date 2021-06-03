# frozen_string_literal: true

require "dry/core/deprecations"
require "tempfile"

RSpec.describe Dry::Core::Deprecations do
  let(:log_file) do
    Tempfile.new("dry_deprecations")
  end

  before do
    Dry::Core::Deprecations.set_logger!(log_file)
  end

  let(:log_output) do
    log_file.close
    log_file.open.read
  end

  describe ".warn" do
    it "logs a warning message" do
      Dry::Core::Deprecations.warn("hello world")
      expect(log_output).to include("[deprecated] hello world")
    end

    it "logs a tagged message" do
      Dry::Core::Deprecations.warn("hello world", tag: :spec)
      expect(log_output).to include("[spec] hello world")
    end

    it "prints information about the caller frame if uplevel is given" do
      Dry::Core::Deprecations.warn("hello world", uplevel: 0)
      expect(log_output).to include(FileUtils.pwd)
    end
  end

  describe ".announce" do
    it "warns about a deprecated method" do
      Dry::Core::Deprecations.announce(:foo, "hello world", tag: :spec, uplevel: 0)
      expect(log_output).to include("[spec] foo is deprecated and will be removed")
      expect(log_output).to include("hello world")
      expect(log_output).to include(FileUtils.pwd)
    end
  end

  shared_examples_for "an entity with deprecated methods" do
    it "deprecates method that is to be removed" do
      res = subject.hello("world")

      expect(res).to eql("hello world")
      expect(log_output).to match(/\[spec\] Test(\.|#)hello is deprecated and will be removed/)
      expect(log_output).to include("is no more")
    end

    it "deprecates a method in favor of another" do
      res = subject.logging("foo")

      expect(res).to eql("log: foo")
      expect(log_output).to match(/\[spec\] Test(\.|#)logging is deprecated and will be removed/)
    end

    it "does not require deprecated method to be defined" do
      res = subject.missing("bar")

      expect(res).to eql("log: bar")
      expect(log_output).to match(/\[spec\] Test(\.|#)missing is deprecated and will be removed/)
    end
  end

  describe ".deprecate_class_method" do
    subject(:klass) do
      Class.new do
        extend Dry::Core::Deprecations[:spec]

        def self.name
          "Test"
        end

        def self.log(msg)
          "log: #{msg}"
        end

        def self.hello(word)
          "hello #{word}"
        end
        deprecate_class_method :hello, message: "is no more"

        def self.logging(msg)
          "logging: #{msg}"
        end
        deprecate_class_method :logging, :log

        deprecate_class_method :missing, :log
      end
    end

    it_behaves_like "an entity with deprecated methods" do
      subject { klass }
    end
  end

  describe ".deprecate" do
    subject(:klass) do
      Class.new do
        extend Dry::Core::Deprecations[:spec]

        def self.name
          "Test"
        end

        def log(msg)
          "log: #{msg}"
        end

        def hello(word)
          "hello #{word}"
        end
        deprecate :hello, message: "is no more"

        def logging(msg)
          "logging: #{msg}"
        end
        deprecate :logging, :log

        deprecate :missing, :log
      end
    end

    it_behaves_like "an entity with deprecated methods" do
      subject { klass.new }
    end
  end

  describe ".deprecate_constant" do
    before do
      module Test
        extend Dry::Core::Deprecations[:spec]

        Obsolete = :no_more

        deprecate_constant(:Obsolete)

        Deprecated = :fix

        deprecate_constant(:Deprecated, message: "Shiny New")
      end
    end

    it "deprecates a constant in favor of another" do
      expect(Test::Obsolete).to be(:no_more)
      expect(log_output).to match(/\[spec\] Test::Obsolete is deprecated and will be removed/)
    end

    it "can have an optional messaage" do
      expect(Test::Deprecated).to be(:fix)
      expect(log_output).to match(/Shiny New/)
    end
  end

  describe ".[]" do
    subject(:klass) do
      Class.new do
        extend Dry::Core::Deprecations[:spec]
      end
    end

    describe ".warn" do
      it "logs a tagged message" do
        klass.warn("hello")
        expect(log_output).to include("[spec] hello")
      end
    end
  end

  describe ".set_logger!" do
    let(:logger) do
      Class.new {
        attr_reader :messages

        def initialize
          @messages = []
        end

        def warn(message)
          messages << message
        end
      }.new
    end

    it "accepts preconfigured logger" do
      Dry::Core::Deprecations.set_logger!(logger)
      Dry::Core::Deprecations.warn("Don't!")

      expect(logger.messages).to eql(%w([deprecated]\ Don't!))
    end
  end

  describe ".logger" do
    let(:stderr) do
      Class.new {
        attr_reader :messages

        def initialize
          @messages = []
        end

        def write(message)
          messages << message
        end

        def close
          messages.freeze
        end
      }.new
    end

    around do |ex|
      $stderr = stderr
      ex.run
      $stderr = STDERR
    end

    before do
      module Dry::Core::Deprecations
        remove_instance_variable :@logger
      end
    end

    let(:default_logger) { Dry::Core::Deprecations.logger }

    it "sets $stderr as a default stream" do
      default_logger.warn("Test")
      expect(stderr.messages).not_to be_empty
    end
  end
end
