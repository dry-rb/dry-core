# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

group :test do
  gem "activesupport"
  gem "dry-inflector"
  gem "dry-types", "~> 1.0"
  gem "inflecto", "~> 0.0", ">= 0.0.2"
end

group :tools do
  gem "pry", platform: :jruby
  gem "pry-byebug", platform: :mri
end
