# frozen_string_literal: true

Test::Project = Class.new(Test::Parent) do
  def to_model
    "Project"
  end
end
