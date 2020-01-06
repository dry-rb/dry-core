# frozen_string_literal: true

source 'https://rubygems.org'

eval_gemfile 'Gemfile.devtools'

gemspec

group :test do
  if RUBY_VERSION >= '2.4'
    gem 'activesupport'
  else
    gem 'activesupport', '~> 4.2'
  end
  gem 'inflecto', '~> 0.0', '>= 0.0.2'
  gem 'dry-types', '~> 1.0'
  gem 'dry-inflector'
end

group :tools do
  gem 'pry-byebug', platform: :mri
  gem 'pry', platform: :jruby
end
