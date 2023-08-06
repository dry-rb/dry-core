# frozen_string_literal: true

RSpec.describe Dry::Core::ClassBuilder do
  subject(:builder) { described_class.new(**options) }

  let(:klass) { builder.call }

  describe "#call" do
    context "anonymous" do
      let(:options) do
        {name: "Test", parent: parent}
      end

      let(:parent) { Class.new }

      it "returns a class constant" do
        expect(klass).to be_instance_of(Class)
      end

      it "sets class name based on provided :name option" do
        expect(klass.name).to eql(options[:name])
      end

      it "uses a parent class provided by :parent option" do
        expect(klass).to be < parent
      end

      it "defines to_s and inspect" do
        expect(klass.to_s).to eql(options[:name])
        expect(klass.inspect).to eql(options[:name])
      end

      it "yields created class" do
        klass = builder.call do |yielded_class|
          yielded_class.class_eval do
            def self.testing; end
          end
        end

        expect(klass).to respond_to(:testing)
      end
    end

    context "namespaced" do
      context "without parent" do
        let(:options) do
          {name: "User", namespace: Test}
        end

        it "creates a class within the given namespace" do
          expect(klass).to be_instance_of(Class)
          expect(klass.name).to eql("Test::User")
          expect(klass.superclass).to be(Test::User)
        end
      end

      context "with parent" do
        let(:parent) do
          Test::Parent = Class.new
        end

        let(:options) do
          {name: "User", parent: parent, namespace: Test}
        end

        it "creates a class with the given parent" do
          expect(klass).to be_instance_of(Class)
          expect(klass.name).to eql("Test::User")
          expect(klass.superclass).to be(Test::User)
          expect(klass.superclass.superclass).to be(Test::Parent)
        end
      end

      context "with mismatched parent class" do
        before do
          Test::InvalidParent = Class.new
          Test::User = Class.new(Test::InvalidParent)
        end

        let(:parent) do
          Test::Parent = Class.new
        end

        let(:options) do
          {name: "User", namespace: Test, parent: parent}
        end

        it "raises meaningful error on mismatched parent class" do
          expect { klass }.to raise_error(
            Dry::Core::ClassBuilder::ParentClassMismatch,
            "Test::User must be a subclass of Test::Parent"
          )
        end
      end

      context "with parent inherited from object" do
        let(:parent) do
          Test::Parent = Class.new
        end

        let(:options) do
          {name: "File", namespace: Test, parent: parent}
        end

        it "does not search for parent class through inheritance" do
          expect(klass.name).to eql("Test::File")
          expect(klass.superclass).to be(Test::File)
          expect(Test::File).not_to be(::File)
        end
      end

      context "autoloaded constant" do
        before do
          Test.module_eval do
            autoload :Project, File.join(__dir__, "../../fixtures/project")
          end
        end

        after do
          Test.module_eval do
            remove_const(:Project)
          end
        end

        let(:parent) do
          Test::Parent = Class.new
        end

        let(:options) do
          {name: "Project", namespace: Test, parent: parent}
        end

        it "autoloads the specified class" do
          expect(klass.name).to eq("Test::Project")
          expect(klass.superclass).to be(Test::Project)
          expect(klass.instance_methods).to include(:to_model)
        end
      end
    end
  end
end
