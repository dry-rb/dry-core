# frozen_string_literal: true

require "dry/core/memoizable"

RSpec.describe Dry::Core::Memoizable do
  extend(Module.new {
    ARGS = [[], [true]].freeze
    BLOCK = [nil, -> { true }].freeze
    KWARGS = [{}, {key: true}].freeze

    def calls(&callback)
      [0, 0, 0, 1, 1, 1].permutation(6) do |args|
        callback.call(*to_obj(*args[0...3]), *to_obj(*args[3...6]))
      end
    end

    def to_obj(arg_id, kwarg_id, block_id)
      call = {
        kwargs: KWARGS[kwarg_id],
        block: BLOCK[block_id],
        args: ARGS[arg_id]
      }

      [call, call.merge(block: BLOCK[block_id]&.call)]
    end
  })

  describe ".new" do
    context "given constructor arguments [*args, **kwargs, &block]" do
      let(:args) { [double("arg")] }
      let(:kwargs) { {key: double("value")} }
      let(:block) { -> { double("block") } }

      let(:object) do
        Class.new do
          include Dry::Core::Memoizable
          attr_reader :args, :kwargs, :block

          def initialize(*args, **kwargs, &block)
            @args = args
            @kwargs = kwargs
            @block = block
          end
        end.new(*args, **kwargs, &block)
      end

      describe "#args" do
        subject { object.args }

        it { is_expected.to eq(args) }
      end

      describe "#kwargs" do
        subject { object.kwargs }

        it { is_expected.to eq(kwargs) }
      end

      describe "#block" do
        subject { object.block }

        it { is_expected.to eq(block) }
      end
    end
  end

  describe "Memoizer#klass" do
    let(:spy) { double("spy") }

    context "given a base class including [Memoizable]" do
      context "given a superclass [BasicObject]" do
        let(:object) do
          Class.new(BasicObject) do
            include Dry::Core::Memoizable
            memoize :call

            def initialize(spy)
              @spy = spy
            end

            def call
              @spy.call
            end
          end.new(spy)
        end

        describe "#call" do
          before do
            expect(spy).to receive(:call).and_return(returns).once
          end

          subject { 2.times.map { object.call } }

          let(:returns) { double("returns") }

          it { is_expected.to eq([returns, returns]) }
        end
      end

      context "given a superclass [Object]" do
        calls do |call1, input1, call2, input2|
          describe [input1, input2] do
            let(:spy) { double("spy") }
            let(:object) do
              Class.new(Struct.new(:spy)) do
                include Dry::Core::Memoizable
                memoize :call1, :call2, :call

                def method_missing(method, *args, **kwargs, &block)
                  super unless respond_to_missing?(method)

                  spy.public_send(method, {args: args, kwargs: kwargs, block: block&.call})
                end

                def respond_to_missing?(method, *)
                  [:call1, :call2, :call].include?(method)
                end
              end.new(spy)
            end

            let(:output1) { double("output1") }
            let(:output2) { double("output2") }
            let(:output3) { double("output3") }
            let(:output4) { double("output4") }

            let(:output) { [output1, output2, output3, output4] }

            before do
              expect(spy).to receive(:call1).with(input1).and_return(output1).once
              expect(spy).to receive(:call2).with(input2).and_return(output2).once

              expect(spy).to receive(:call).with(input1).and_return(output3).once
              expect(spy).to receive(:call).with(input2).and_return(output4).once
            end

            subject do
              2.times.each_with_object([]) do |_, acc|
                acc << object.call1(*call1[:args], **call1[:kwargs], &call1[:block])
                acc << object.call2(*call2[:args], **call2[:kwargs], &call2[:block])

                acc << object.call(*call1[:args], **call1[:kwargs], &call1[:block])
                acc << object.call(*call2[:args], **call2[:kwargs], &call2[:block])
              end
            end

            describe "given a non-frozen object" do
              it { is_expected.to include(*output) }
            end

            describe "given a frozen object" do
              let(:object) { super().freeze }

              it { is_expected.to include(*output) }
            end
          end
        end
      end
    end

    context "given a base class not including [Memoizable]" do
      let(:object) do
        Class.new(Struct.new(:spy)) do
          def call
            spy.call
          end
        end.new(spy)
      end

      describe "#call" do
        before do
          expect(spy).to receive(:call).and_return(returns).twice
        end

        let(:returns) { double("returns") }

        subject { 2.times.map { object.call } }

        it { is_expected.to eq([returns, returns]) }
      end
    end
  end
end
