module DelayHenka
  module Web
    module Admin
      class ScheduledChangesController < DelayHenka.base_view_controller.constantize

        before_action :set_scheduled_change, only: %i(destroy)

        def index
          @changes = ScheduledChange.order('created_at DESC')
        end

        def destroy
          @change.destroy!
          redirect_back fallback_location: web_admin_scheduled_changes_path, flash: {success: 'Destroy succeeded'}
        end

        private

        def set_scheduled_change
          @change = ScheduledChange.find(params[:id])
        end

      end
    end
  end
end
