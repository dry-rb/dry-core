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
          parameters = method.parameters

          if parameters.empty?
            key = method.name.hash
            module_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{method.name}
                if @__memoized__.key?(#{key})
                  @__memoized__[#{key}]
                else
                  @__memoized__[#{key}] = super
                end
              end
            RUBY
          else
            mapping = parameters.to_h { |k, v = nil| [k, v] }
            params, binds = declaration(parameters, mapping)

            module_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{method.name}(#{params.join(", ")})
                key = [:"#{method.name}", #{binds.join(", ")}].hash

                if @__memoized__.key?(key)
                  @__memoized__[key]
                else
                  @__memoized__[key] = super
                end
              end
            RUBY

            if respond_to?(:ruby2_keywords, true) && mapping.key?(:reyrest)
              ruby2_keywords(method.name)
            end
          end
        end

        # @api private
        def declaration(definition, lookup)
          params = []
          binds = []
          defined = {}

          definition.each do |type, name|
            mapped_type = map_bind_type(type, lookup, defined) do
              raise ::NotImplementedError, "type: #{type}, name: #{name}"
            end

            if mapped_type
              defined[mapped_type] = true
              bind = name || make_bind_name(binds.size)

              binds << bind
              params << param(bind, mapped_type)
            end
          end

          [params, binds]
        end

        # @api private
        def make_bind_name(idx)
          :"__lv_#{idx}__"
        end

        # @api private
        def map_bind_type(type, original_params, defined_types) # rubocop:disable Metrics/PerceivedComplexity
          case type
          when :req
            :reqular
          when :rest, :keyreq, :keyrest, :block
            type
          when :opt
            if original_params.key?(:rest) || defined_types[:rest]
              nil
            else
              :rest
            end
          when :key
            if original_params.key?(:keyrest) || defined_types[:keyrest]
              nil
            else
              :keyrest
            end
          else
            yield
          end
        end

        # @api private
        def param(name, type)
          case type
          when :reqular
            name
          when :rest
            "*#{name}"
          when :keyreq
            "#{name}:"
          when :keyrest
            "**#{name}"
          when :block
            "&#{name}"
          end
        end
      end
    end
  end
end
