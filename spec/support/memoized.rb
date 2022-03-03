# frozen_string_literal: true

class Memoized
  include Module.new {
    def test9
      # NOP
    end
  }
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

  if RUBY_VERSION >= "2.7"
    module_eval(<<~RUBY, __FILE__, __LINE__ + 1)
      def test9(...)
        super
      end
    RUBY
  end

  def self.memoize_methods
    @memoized ||= begin
      if RUBY_VERSION >= "2.7"
        memoize :test1, :test2, :test3, :test4, :test5, :test6, :test7, :test8, :test9
      else
        memoize :test1, :test2, :test3, :test4, :test5, :test6, :test7, :test8
      end

      true
    end
  end
end
