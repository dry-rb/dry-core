require 'dry/core/class_builder'

RSpec.describe Dry::Core::ClassBuilder do
  subject(:builder) { described_class.new(options) }

  let(:klass) { builder.call }

  describe '#call' do
    context 'anonymous' do
      let(:options) do
        { name: 'Test', parent: parent }
      end

      let(:parent) { Class.new }

      it 'returns a class constant' do
        expect(klass).to be_instance_of(Class)
      end

      it 'sets class name based on provided :name option' do
        expect(klass.name).to eql(options[:name])
      end

      it 'uses a parent class provided by :parent option' do
        expect(klass).to be < parent
      end

      it 'defines to_s and inspect' do
        expect(klass.to_s).to eql(options[:name])
        expect(klass.inspect).to eql(options[:name])
      end

      it 'yields created class' do
        klass = builder.call do |yielded_class|
          yielded_class.class_eval do
            def self.testing; end
          end
        end

        expect(klass).to respond_to(:testing)
      end
    end

    context 'namespaced' do
      context 'with parent' do
        let(:parent) { Class.new }

        let(:options) do
          { name: 'User', parent: parent }
        end
      end

      context 'without parent' do
        let(:options) do
          { name: 'User', namespace: Test }
        end

        it 'creates a class within the given namespace' do
          expect(klass).to be_instance_of(Class)
          expect(klass.name).to eql('Test::User')
          expect(klass.superclass).to be(Test::User)
        end
      end
    end
  end
end
