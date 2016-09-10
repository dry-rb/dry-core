require 'logger'

module Dry
  module Core
    module Deprecations
      class << self
        def warn(msg)
          logger.warn(msg.gsub(/^\s+/, ''))
        end

        def announce(name, msg)
          warn(deprecation_message(name, msg))
        end

        def deprecation_message(name, msg)
          <<-MSG
            #{name} is deprecated and will be removed in the next major version
            #{message(msg)}
          MSG
        end

        def deprecated_method_message(old, new = nil, msg = nil)
          if new
            deprecation_message(old, <<-MSG)
              Please use #{new} instead.
              #{msg}
            MSG
          else
            deprecation_message(old, msg)
          end
        end

        def message(msg)
          <<-MSG
            #{msg}
            #{caller.detect { |l| l !~ /(lib\/dry\/core)|(gems)/ }}
          MSG
        end

        def logger(tag = nil, output = nil)
          if defined?(@logger)
            @logger
          else
            set_logger!(output: output, tag: tag)
          end
        end

        def set_logger!(output: nil, tag: nil)
          @logger = Logger.new(output || $stdout)
          @logger.formatter = proc { |_severity, _datetime, _progname, msg|
            "[#{tag || 'deprecated'}] #{msg}\n"
          }
          @logger
        end
      end

      def deprecate(old_name, new_name = nil, message: nil)
        full_msg = Deprecations.deprecated_method_message(
          "#{self.name}##{old_name}",
          new_name ? "#{self.name}##{new_name}" : nil,
          message
        )

        if new_name
          undef_method old_name
          define_method(old_name) do |*args, &block|
            Deprecations.warn(full_msg)
            __send__(new_name, *args, &block)
          end
        else
          aliased_name = :"#{old_name}_without_deprecation"
          alias_method aliased_name, old_name
          private aliased_name
          undef_method old_name
          define_method(old_name) do |*args, &block|
            Deprecations.warn(full_msg)
            __send__(aliased_name, *args, &block)
          end
        end
      end

      def deprecate_class_method(old_name, new_name = nil, message: nil)
        full_msg = Deprecations.deprecated_method_message(
          "#{self.name}.#{old_name}",
          new_name ? "#{self.name}.#{new_name}" : nil,
          message
        )

        meth = new_name ? method(new_name) : method(old_name)

        singleton_class.instance_exec do
          undef_method old_name
          define_method(old_name) do |*args, &block|
            Deprecations.warn(full_msg)
            meth.call(*args, &block)
          end
        end
      end
    end
  end
end
