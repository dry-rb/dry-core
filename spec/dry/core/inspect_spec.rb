# frozen_string_literal: true

require "pp"

RSpec.describe Dry::Core::Inspect do
  subject(:inspect) { Dry::Core::Inspect.new(:fullname, :secret_question_answer, **value_methods_map) }

  let(:value_methods_map) { {} }
  let(:klass) do
    Class.new do
      attr_reader :fullname, :secret_question_answer
      private :fullname, :secret_question_answer

      def initialize(fullname, secret_question_answer)
        @fullname = fullname
        @secret_question_answer = secret_question_answer
      end

      private

      def secret_question_answer_encrypted
        @secret_question_answer * 42
      end
    end
  end
  let(:instance) { klass.new("John Doe", 42) }

  before { klass.include(inspect) }

  it "defines a pretty_print method" do
    expect(instance.pretty_inspect)
      .to match(/\A#<#<Class:0x[a-f0-9]{16}>:0x[a-f0-9]{16}\n fullname="John Doe",\n secret_question_answer=42>\n\z/)
  end

  it "defines an inspect method" do
    expect(instance.inspect)
      .to match(/\A#<#<Class:0x[a-f0-9]{16}>:0x[a-f0-9]{16} fullname="John Doe", secret_question_answer=42>\z/)
  end

  context "with a non-anonymous class" do
    before { stub_const("User", klass) }

    it "uses the class name in the pretty_inspect output" do
      expect(instance.pretty_inspect).to eq("#<User fullname=\"John Doe\", secret_question_answer=42>\n")
    end

    it "uses the class name in the inspect output" do
      expect(instance.inspect).to eq("#<User fullname=\"John Doe\", secret_question_answer=42>")
    end
  end

  context "with a value method given" do
    let(:value_methods_map) { {secret_question_answer: :secret_question_answer_encrypted} }

    it "uses the value method in the pretty_inspect output" do
      expect(instance.pretty_inspect)
        .to match(/\A#<#<Class:0x[a-f0-9]{16}>:0x[a-f0-9]{16}\n fullname="John Doe",\n secret_question_answer=1764>\n\z/)
    end

    it "uses the value method in the inspect output" do
      expect(instance.inspect)
        .to match(/\A#<#<Class:0x[a-f0-9]{16}>:0x[a-f0-9]{16} fullname="John Doe", secret_question_answer=1764>\z/)
    end
  end
end
