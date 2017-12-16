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
  gem 'dry-inflector', git: 'https://github.com/dry-rb/dry-inflector', branch: 'master'
end

group :tools do
  gem 'pry-byebug', platform: :mri
  gem 'pry', platform: :jruby
  gem 'rubocop'
end
