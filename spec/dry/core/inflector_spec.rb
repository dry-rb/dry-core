# frozen_string_literal: true

RSpec.describe Dry::Core::Inflector do
  shared_examples "an inflector" do
    it "singularises" do
      expect(api.singularize("tasks")).to eql("task")
    end

    it "pluralizes" do
      expect(api.pluralize("task")).to eql("tasks")
    end

    it "camelizes" do
      expect(api.camelize("task_user")).to eql("TaskUser")
    end

    it "underscores" do
      expect(api.underscore("TaskUser")).to eql("task_user")
    end

    it "demodulizes" do
      expect(api.demodulize("Task::User")).to eql("User")
    end

    it "classifies" do
      expect(api.classify("task_user/name")).to eql("TaskUser::Name")
    end
  end

  shared_examples "an inflector with constantize" do
    it "constantizes" do
      expect(api.constantize("String")).to be String
    end
  end

  subject(:api) { Dry::Core::Inflector }

  context "with detected inflector" do
    before do
      if api.instance_variables.include?(:@inflector)
        api.__send__(:remove_instance_variable, :@inflector)
      end
    end

    it "prefers ActiveSupport::Inflector" do
      expect(api.inflector).to be ::ActiveSupport::Inflector
    end
  end

  context "with automatic detection" do
    before do
      if api.instance_variables.include?(:@inflector)
        api.__send__(:remove_instance_variable, :@inflector)
      end
    end

    it "automatically selects an inflector backend" do
      expect(api.inflector).not_to be nil
    end
  end

  context "with ActiveSupport::Inflector" do
    before do
      api.select_backend(:activesupport)
    end

    it "is ActiveSupport::Inflector" do
      expect(api.inflector).to be(::ActiveSupport::Inflector)
    end

    it_behaves_like "an inflector"
    it_behaves_like "an inflector with constantize"
  end

  context "with Inflecto" do
    before do
      api.select_backend(:inflecto)
    end

    it "is Inflecto" do
      expect(api.inflector).to be(::Inflecto)
    end

    it_behaves_like "an inflector"
    it_behaves_like "an inflector with constantize"
  end

  context "with Dry::Inflector" do
    before do
      api.select_backend(:dry_inflector)
    end

    it "is Dry::Inflector" do
      expect(api.inflector).to be_a(Dry::Inflector)
    end

    it_behaves_like "an inflector"
  end

  context "an unrecognized inflector library is selected" do
    it "raises a NameError" do
      expect { api.select_backend(:foo) }.to raise_error(NameError)
    end
  end
end
