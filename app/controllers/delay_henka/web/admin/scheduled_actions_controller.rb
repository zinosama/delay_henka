module DelayHenka
  module Web
    module Admin
      class ScheduledActionsController < DelayHenka.base_view_controller.constantize

        before_action :set_scheduled_action, only: %i(destroy)

        def index
          @actions = ScheduledAction.order('created_at DESC')
        end

        def destroy
          @action.destroy!
          redirect_back fallback_location: web_admin_scheduled_actions_path, flash: { success: 'Destroy succeeded' }
        end

        private

        def set_scheduled_action
          @action = ScheduledAction.find(params[:id])
        end

      end
    end
  end
end
