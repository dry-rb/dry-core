# frozen_string_literal: true

RSpec.describe Dry::Core::DescendantsTracker do
  before do
    module Test
      class Parent
        extend Dry::Core::DescendantsTracker
      end

      class Child < Parent
      end

      class Grandchild < Child
      end
    end
  end

  it "tracks descendants" do
    expect(Test::Parent.descendants).to eql([Test::Grandchild, Test::Child])
  end
end
