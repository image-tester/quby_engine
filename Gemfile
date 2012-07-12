source "http://rubygems.org"

# Declare your gem's dependencies in quby.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# jquery-rails is used by the dummy application
gem "jquery-rails"
gem "bson_ext", "~> 1.5.2"

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
#
# OLD GEMFILE:
#source 'http://rubygems.org'

gem 'open4'
gem 'wirble'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

platforms :ruby, :jruby do
  gem 'therubyracer'
end

group :test, :development do
  gem "rspec-rails"
  gem 'capybara'

  gem 'guard-rspec'
  gem 'spork'
  gem 'guard-spork'

  gem "fakefs", :require => "fakefs/safe"
end

group :test do
  gem 'fuubar'
  gem 'timecop'
end
