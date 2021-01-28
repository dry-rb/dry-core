# frozen_string_literal: true

module Dry
  module Core
    module Memoizable
      MEMOIZED_HASH = {}.freeze

      module ClassInterface
        module Base
          def memoize(*names)
            prepend(Memoizer.new(self, names))
          end
        end

        module BasicObject
          include Base

          def new(*)
            obj = super
            obj.instance_eval { @__memoized__ = MEMOIZED_HASH.dup }
            obj
          end
        end

        module Object
          include Base

          def new(*)
            obj = super
            obj.instance_variable_set(:'@__memoized__', MEMOIZED_HASH.dup)
            obj
          end

          if respond_to?(:ruby2_keywords, true)
            ruby2_keywords(:new)
          end
        end
      end

      def self.included(klass)
        super

        if klass <= Object
          klass.extend(ClassInterface::Object)
        else
          klass.extend(ClassInterface::BasicObject)
        end
      end

      # @api private
      class Memoizer < Module
        # @api private
        def initialize(klass, names)
          names.each do |name|
            define_memoizable(
              method: klass.instance_method(name)
            )
          end
        end

        private

        # @api private
        def define_memoizable(method:)
          module_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{method.name}(#{to_declaration(method.parameters)})
              key = [Kernel.__method__] + Kernel.local_variables.map { |var| Kernel.eval(var.to_s) }

              if @__memoized__.key?(key)
                @__memoized__[key]
              else
                @__memoized__[key] = super
              end
            end
          RUBY

          if respond_to?(:ruby2_keywords, true)
            ruby2_keywords(method.name)
          end
        end

        # @api private
        def to_declaration(params, lookup = params.to_h)
          params.map do |type, name|
            case type
            when :req
              name
            when :rest
              "*#{name}"
            when :keyreq
              "#{name}:"
            when :keyrest
              "**#{name}"
            when :block
              "&#{name}"
            when :opt
              lookup.key?(:rest) ? nil : "*args"
            when :key
              lookup.key?(:keyrest) ? nil : "**kwargs"
            else
              raise NotImplementedError, "type: #{type}, name: #{name}"
            end
          end.compact.join(", ")
        end
      end
    end
  end
end
