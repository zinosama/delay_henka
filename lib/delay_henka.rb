require "delay_henka/engine"
require 'haml'
require 'pry'

module DelayHenka

  module Model
    extend ActiveSupport::Concern
    included do
      has_many :upcoming_changes,
        ->{ staged.order('created_at DESC') },
        class_name: 'DelayHenka::ScheduledChange',
        as: :changeable
    end
  end

  mattr_accessor :base_view_controller
  @@base_view_controller = 'DelayHenka::ApplicationController'

  def self.setup
    yield self
  end

end
