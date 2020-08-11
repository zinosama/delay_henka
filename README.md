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
    @product = SomeModel.find(params[:id])
    delayed_changes = some_params.extract!(:discount_pct, :price)
    if @product.update some_params.except(:discount_pct, :price)
      result = DelayHenka::ScheduledChange.schedule(record: @product, changes: delayed_changes, by_id: current_user.id, time_zone: Time.zone.name)
      if result.ok? # returns a Keka object
        redirect_to #..., success
      else
        # no change is scheduled. display error and have user try again.
        flash.now[:error] = result.msg
        render :edit
      end
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

# To schedule the worker that applies all changes
# and actions based on time zone, in your
# sidekiq confiz/schedule.yml,
apply_scheduled_changes_and_actions:
  cron: "0 * * * *"
  class: DelayHenka::UpdatesOnValidTimeZonesWorker
  queue: default
```

### States of ScheduledChange

* STAGED:     initial state
* REPLACED:   replaced by another record updating the same attribute
* COMPLETED:  change is applied successfully
* ERRORED:    change failed to be applied

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'delay_henka'
```

And then execute:
```bash
$ bundle
```

## Release Process

PREREQUISITE: Access to Gemfury

1. Create a new release branch off of master. A good release branch might be `release-v0.2.0`.
2. Bump the version in `version.rb`, `Gemfile.lock`. Move the description in `CHANGELOG.md` under its own heading.
3. Create PR for these changes. Merge PR with approval.
4. Create a tag for your version (on branch master). Ex: `git tag -a v0.2.0 -m 'v0.2.0'`.
5. Push tag: `git push --tags`
6. Push to gemfury: `git push fury master` (If you haven’t yet done so, you may need to add the gemfury remote: `git remote add fury https://<your_account>@git.fury.io/chowbus/<package-name>.git`)
