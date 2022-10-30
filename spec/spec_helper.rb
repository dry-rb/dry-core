# frozen_string_literal: true

require_relative "support/coverage"
require_relative "support/shared_examples/memoizable"
require_relative "support/shared_examples/container"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rspec/version"

begin
  require "pry"
  require "pry-byebug"
rescue LoadError
end

require "dry/core"

module Test
  def self.remove_constants
    constants.each(&method(:remove_const))
  end
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  if RSpec::Version::STRING >= "4.0.0"
    raise "This condition block can be safely removed"
  else
    config.expect_with :rspec do |expectations|
      expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    end

    config.mock_with :rspec do |mocks|
      mocks.verify_partial_doubles = true
    end

    config.shared_context_metadata_behavior = :apply_to_host_groups
  end

  config.after do
    Test.remove_constants
  end

  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  config.filter_run_when_matching :focus

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options.
  config.example_status_persistence_file_path = "spec/examples.txt"

  config.disable_monkey_patching!

  config.warnings = true

  # Use the documentation formatter for detailed output
  config.default_formatter = "doc" if config.files_to_run.one?

  config.order = :random

  Kernel.srand config.seed
end
