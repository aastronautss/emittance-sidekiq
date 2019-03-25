# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

require 'bundler/setup'
require 'emittance/sidekiq'

require 'sidekiq/testing'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after(:each) do
    Sidekiq::Worker.clear_all
    Emittance::Sidekiq::Dispatcher.clear_registrations!
    Emittance::Sidekiq.callback_repository.clear
  end
end
