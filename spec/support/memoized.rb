# frozen_string_literal: true

class Memoized
  include Module.new {
    def test9
      # NOP
    end
  }
  include Dry::Core::Memoizable

  def test1(arg1, *args, kwarg1:, kwarg2: "default", **kwargs, &)
    # NOP
  end

  def test2(arg1, arg2 = "default", *args, &)
    # NOP
  end

  def test3(&)
    # NOP
  end

  def test4
    # NOP
  end

  def test5(args, *)
    # NOP
  end

  def test6(kwargs, **)
    # NOP
  end

  def test7(args, kwargs, *, **)
    # NOP
  end

  def test8(args = 1, kwargs = 2, *, **)
    # NOP
  end

  def test9(...)
    super
  end

  def self.memoize_methods
    @memoized ||= begin
      memoize :test1, :test2, :test3, :test4, :test5, :test6, :test7, :test8, :test9
      true
    end
  end
end
