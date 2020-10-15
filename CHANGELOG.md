# CHANGELOG

## Unreleased

## Version 0.7.0

**Breaking changes:**

* Add `ScheduledAction#submitted_by_email`, deprecate `ScheduledAction#submitted_by_id`
* `ScheduledAction.schedule` now accepts `by_email` instead of `by_id`
* Add `ScheduledChange#submitted_by_email`, deprecate `ScheduledChange#submitted_by_id`
* `ScheduledChange.schedule` now accepts `by_email` instead of `by_id`

## Version 0.6.2
* require time_zone as parameter on schedule method for ScheduledChange and ScheduledAction.
* Add time_zone to query inside ApplyActionsWorker and ApplyChangesWorker.
* wrap ApplyActionsWorker and ApplyChangesWorker in UpdatesOnValidTimeZonesWorker.

## Version 0.6.1
* Introduce time_zone as parameter on schedule method for ScheduledChange and ScheduledAction.

## Version 0.6.0
* Add service_region_id and time_zone migrations.

## Version 0.5.3
Unrecorded.
