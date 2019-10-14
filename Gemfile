source 'https://rubygems.org'

gemspec

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :test do
  if RUBY_VERSION >= '2.4'
    gem 'activesupport'
  else
    gem 'activesupport', '~> 4.2'
  end
  gem 'inflecto', '~> 0.0', '>= 0.0.2'
  gem 'codeclimate-test-reporter', require: false
  gem 'simplecov', require: false
  gem 'dry-types', '~> 1.0'
  gem 'dry-inflector'
end

group :tools do
  gem 'pry-byebug', platform: :mri
  gem 'pry', platform: :jruby
  gem 'ossy', github: 'solnic/ossy', branch: 'master'
end
