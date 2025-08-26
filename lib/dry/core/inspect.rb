# frozen_string_literal: true

module Dry
  module Core
    class Inspect < ::Module
      def initialize(*attributes, **value_methods_map)
        super()

        define_inspect_methods(attributes.flatten(1), **value_methods_map)
      end

      private

      def define_inspect_methods(attributes, **value_methods_map)
        define_inspect_method(attributes, **value_methods_map)
        define_pretty_print(attributes, **value_methods_map)
      end

      def define_inspect_method(attributes, **value_methods_map)
        define_method(:inspect) do
          instance_inspect = if self.class.name
                               "#<#{self.class.name}"
                             else
                               Kernel.instance_method(:to_s).bind(self).call.chomp!(">")
                             end

          inspect = attributes.map { |name|
            "#{name}=#{__send__(value_methods_map[name] || name).inspect}"
          }.join(", ")
          "#{instance_inspect} #{inspect}>"
        end
      end

      def define_pretty_print(attributes, **value_methods_map)
        define_method(:pretty_print) do |pp|
          object_group_method = self.class.name ? :object_group : :object_address_group
          pp.public_send(object_group_method, self) do
            pp.seplist(attributes, -> { pp.text "," }) do |name|
              pp.breakable " "
              pp.group(1) do
                pp.text name.to_s
                pp.text "="
                pp.pp __send__(value_methods_map[name] || name)
              end
            end
          end
        end
      end
    end
  end
end
