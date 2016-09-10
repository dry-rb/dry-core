require 'set'

module Dry
  module Core
    module Extensions
      def self.extended(obj)
        super
        obj.instance_variable_set(:@__available_extensions__, {})
        obj.instance_variable_set(:@__loaded_extensions__, Set.new)
      end

      def register_extension(name, &block)
        @__available_extensions__[name] = block
      end

      def load_extensions(*extensions)
        extensions.each do |ext|
          block = @__available_extensions__.fetch(ext) do
            raise ArgumentError, "Unknown extension: #{ext.inspect}"
          end
          unless @__loaded_extensions__.include?(ext)
            block.call
            @__loaded_extensions__ << ext
          end
        end
      end
    end
  end
end
