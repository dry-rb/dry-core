require 'dry/core/deprecations'
require 'tempfile'

RSpec.describe Dry::Core::Deprecations do
  let(:log_file) do
    Tempfile.new('dry_deprecations')
  end

  before do
    Dry::Core::Deprecations.set_logger!(output: log_file, tag: 'spec')
  end

  let(:output) do
    log_file.close
    log_file.open.read
  end

  describe '.warn' do
    it 'logs a warning message' do
      Dry::Core::Deprecations.warn('hello world')
      expect(output).to include('[spec] hello world')
    end
  end

  describe '.announce' do
    it 'warns about a deprecated method' do
      Dry::Core::Deprecations.announce(:foo, 'hello world')
      expect(output).to include('[spec] foo is deprecated and will be removed')
      expect(output).to include('hello world')
    end
  end

  shared_examples_for 'an entity with deprecated methods' do
    it 'deprecates method that is to be removed' do
      res = subject.hello('world')

      expect(res).to eql('hello world')
      expect(output).to match(/\[spec\] Test(\.|#)hello is deprecated and will be removed/)
      expect(output).to include('is no more')
    end

    it 'deprecates a method in favor of another' do
      res = subject.logging('foo')

      expect(res).to eql('log: foo')
      expect(output).to match(/\[spec\] Test(\.|#)logging is deprecated and will be removed/)
    end
  end

  describe '.deprecate_class_method' do
    subject(:klass) do
      Class.new do
        extend Dry::Core::Deprecations

        def self.name
          'Test'
        end

        def self.log(msg)
          "log: #{msg}"
        end

        def self.hello(word)
          "hello #{word}"
        end
        deprecate_class_method :hello, message: 'is no more'

        def self.logging(msg)
          "logging: #{msg}"
        end
        deprecate_class_method :logging, :log
      end
    end

    it_behaves_like 'an entity with deprecated methods' do
      subject { klass }
    end
  end

  describe '.deprecate' do
    subject(:klass) do
      Class.new do
        extend Dry::Core::Deprecations

        def self.name
          'Test'
        end

        def log(msg)
          "log: #{msg}"
        end

        def hello(word)
          "hello #{word}"
        end
        deprecate :hello, message: 'is no more'

        def logging(msg)
          "logging: #{msg}"
        end
        deprecate :logging, :log
      end
    end

    it_behaves_like 'an entity with deprecated methods' do
      subject { klass.new }
    end
  end
end
