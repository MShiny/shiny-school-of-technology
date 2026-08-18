ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # This app builds test data explicitly in each test rather than via fixtures,
    # so fixture auto-loading is disabled (it also requires Postgres superuser
    # privileges to validate foreign keys, which the app's database role does not have).

    # Add more helper methods to be used by all tests here...
  end
end
