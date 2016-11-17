$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rspec/version'

if RUBY_ENGINE == 'ruby' && ENV['CI'] == 'true'
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

begin
  require 'byebug'
rescue LoadError
end

require 'dry/core'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  if RSpec::Version::STRING >= '4.0.0'
    raise 'This condition block can be safely removed'
  else
    config.expect_with :rspec do |expectations|
      expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    end

    config.mock_with :rspec do |mocks|
      mocks.verify_partial_doubles = true
    end

    config.shared_context_metadata_behavior = :apply_to_host_groups
  end

  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  config.filter_run_when_matching :focus

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options.
  config.example_status_persistence_file_path = 'spec/examples.txt'

  config.disable_monkey_patching!

  config.warnings = true

  # Use the documentation formatter for detailed output
  config.default_formatter = 'doc' if config.files_to_run.one?

  # Print the n slowest examples and example groups at the
  # end of the spec run
  config.profile_examples = 3

  config.order = :random

  Kernel.srand config.seed
end
