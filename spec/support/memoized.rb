# frozen_string_literal: true

class Memoized
  include Dry::Core::Memoizable

  def test1(arg1, *args, kwarg1:, kwarg2: "default", **kwargs, &block)
    # NOP
  end

  def test2(arg1, arg2 = "default", *args, &block)
    # NOP
  end

  def test3(&block)
    # NOP
  end

  def test4
    # NOP
  end

  memoize :test1, :test2, :test3, :test4
end
