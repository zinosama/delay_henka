# Delay Henka

'Henka' is Japanese for 'change'.

`DelayHenka` is a Rails engine for managing delayed update of attributes. This is built to ensure that important attributes (such as price of a product, for instance) can be updated anytime but will not impact users until a specific time later in the day (maybe 2am in the morning, when it's safe to apply those changes).

Granted, there're other strategies with higher level of integrity (such as versioning the resources). This implementation is merely a low-cost solution that solves the problem to a reasonable extent.

## Usage

In the including application,
```ruby
# copy over migrations
`bundle exec rails delay_henka:install:migrations`
`bundle exec rails db:migrate`

# config/routes.rb
mount DelayHenka::Engine, at: '/delay_henka'

# Create an initilazer delay_henka.rb
DelayHenka.setup do |config|
  # Sets the base controller of the engine views
  config.base_view_controller = 'Backend::BaseController'
end

# In your model that you want to have delayed updates,
class SomeModel < ApplicationRecord
  # This gives instances of this class `#upcoming_changes` association with staged ScheduledChange
  include DelayHenka::Model
end

# In your controller (or factory service),
class SomeController
  def update
    product = SomeModel.find(params[:id])
    delayed_changes = some_params.extract!(:discount_pct, :price)
    if product.update some_params.except(:discount_pct, :price)
      DelayHenka::ScheduledChange.schedule(record: product, changes: delayed_changes, by_id: current_user.id)
      redirect_to #..., success
    else
      render :edit
    end
  end
end

# To view scheduled changes associated with a record,
# some_view.html.haml
- if @product.upcoming_changes.any?
  = render 'delay_henka/web/admin/scheduled_changes/summary_table', scheduled_changes: @product.upcoming_changes

# To view all scheduled changes, use this link:
delay_henka.web_admin_scheduled_changes_path

# To schedule the worker that applies all changes,
# in your sidekiq config/schedule.yml,
apply_scheduled_changes:
  cron: "0 1 * * *"
  class: DelayHenka::ApplyChangesWorker
  queue: default
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'delay_henka'
```

And then execute:
```bash
$ bundle
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
