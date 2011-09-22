require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'

  Dir[Rails.root.join('db', 'functions', '*.rb')].each do |path|
    filename = File.basename(path)
    q_key = filename.match(/^(.*)\.rb$/)[1]
    next if  Function.find_by_name(q_key)
    Function.create(:name => q_key, :definition => File.read(path))
  end

  Dir[Rails.root.join('db', 'questionnaires', '*.rb')].each do |path|
    filename = File.basename(path)
    q_key = filename.match(/^(.*)\.rb$/)[1]
    next if Questionnaire.find_by_key q_key

    begin
      #puts "Creating Questionnaire #{q_key}"
      q = Questionnaire.new(:key => q_key, :definition => File.read(path))
      q.save!(:validate => false)
    rescue => e
      puts "Questionnaire #{q_key} was not saved because it has errors:\n #{e}"
    end
  end

end

Spork.each_run do
  # This code will be run each time you run your specs.

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, comment the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = false
  end
end
