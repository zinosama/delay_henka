# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
require 'sidekiq/testing'
require 'keka'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../test/dummy/config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.before(:each) do
    Sidekiq::Worker.clear_all
  end

  config.before(:suite) do
    ActiveRecord::Migration.create_table(:delay_henka_foos) do |t|
      t.string :attr_chars
      t.integer :attr_int
    end

    module DelayHenka
      class Foo < ApplicationRecord
        validates :attr_chars, presence: true, uniqueness: true
        validates :attr_int, numericality: { greater_than: 1 }, allow_nil: true
        after_initialize -> { self.attr_chars ||= 'init' }, if: :new_record?

        def no_arity
        end

        def single_arity(arg)
        end

        def err_action(arg)
          raise "#{arg['some_arg']} raised an exception"
        end
      end
    end
  end

  config.after(:suite) do
    ActiveRecord::Migration.drop_table(:delay_henka_foos)
  end
end
