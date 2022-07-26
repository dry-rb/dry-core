# frozen_string_literal: true

require "zeitwerk"

require "dry/core/constants"
require "dry/core/errors"
require "dry/core/version"

# :nodoc:
module Dry
  # :nodoc:
  module Core
    include Constants

    def self.loader
      @loader ||= Zeitwerk::Loader.new.tap do |loader|
        root = File.expand_path("..", __dir__)
        loader.tag = "dry-core"
        loader.inflector = Zeitwerk::GemInflector.new("#{root}/dry-core.rb")
        loader.push_dir(root)
        loader.ignore(
          "#{root}/dry-core.rb",
          "#{root}/dry/core/{constants,errors,version}.rb"
        )
      end
    end

    loader.setup
  end
end
