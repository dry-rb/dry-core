source 'https://rubygems.org'

gemspec

group :test do
  if RUBY_VERSION >= '2.4'
    gem 'activesupport'
  else
    gem 'activesupport', '~> 4.2'
  end
  gem 'inflecto', '~> 0.0', '>= 0.0.2'
  gem 'codeclimate-test-reporter', require: false
  gem 'simplecov', require: false
  gem 'dry-types'
end

group :tools do
  gem 'byebug', platform: :mri
  gem 'rubocop'
end
