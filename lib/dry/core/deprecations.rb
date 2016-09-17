require 'logger'

module Dry
  module Core
    # An extension for issueing warnings on using deprecated methods.
    #
    # @example
    #
    #   class Foo
    #     def self.old_class_api; end
    #     def self.new_class_api; end
    #
    #     deprecate_class_method :old_class_api, :new_class_api
    #
    #     def old_api; end
    #     def new_api; end
    #
    #     deprecate_method :old_api, :new_api, "old_api is no-no"
    #   end
    #
    # @example You also can use this module for your custom messages
    #
    #   Dry::Core::Deprecations.announce("Foo", "use bar instead")
    #   Dry::Core::Deprecations.warn("Baz is going to be removed soon")
    #
    # @api public
    module Deprecations
      class << self
        # Prints a warning
        #
        # @param [String] msg Warning string
        def warn(msg)
          logger.warn(msg.gsub(/^\s+/, ''))
        end

        # Wraps arguments with a standard message format and prints a warning
        #
        # @param [Object] name what is deprecated
        # @param [String] msg additional message usually containing upgrade instructions
        def announce(name, msg)
          warn(deprecation_message(name, msg))
        end

        # @api private
        def deprecation_message(name, msg)
          <<-MSG
            #{name} is deprecated and will be removed in the next major version
            #{message(msg)}
          MSG
        end

        # @api private
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

        # @api private
        def message(msg)
          <<-MSG
            #{msg}
            #{caller.detect { |l| l !~ %r{(lib/dry/core)|(gems)} }}
          MSG
        end

        # Returns the logger used for printing warnings.
        # You can provide your own with .set_logger!
        #
        # @param [String, Symbol] tag optional prefix for messages
        # @param [IO] output output stream
        #
        # @return [Logger]
        def logger(tag = nil, output = nil)
          if defined?(@logger)
            @logger
          else
            set_logger!(output: output, tag: tag)
          end
        end

        # Sets a custom logger. This is a global settings.
        #
        # @option [IO] output output stream for messages
        # @option [String, Symbol] tag optional prefix
        #
        # TODO: Add support for per-module loggers so that at least
        #       tag option won't conflict.
        def set_logger!(output: nil, tag: nil)
          @logger = Logger.new(output || $stdout)
          @logger.formatter = proc { |_severity, _datetime, _progname, msg|
            "[#{tag || 'deprecated'}] #{msg}\n"
          }
          @logger
        end
      end

      # Mark instance method as deprecated
      #
      # @param [Symbol] old_name deprecated method
      # @param [Symbol] new_name replacement (not required)
      # @option [String] message optional deprecation message
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

      # Mark class-level method as deprecated
      #
      # @param [Symbol] old_name deprecated method
      # @param [Symbol] new_name replacement (not required)
      # @option [String] message optional deprecation message
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
