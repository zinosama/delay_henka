DelayHenka::Engine.routes.draw do
  namespace :web do
    namespace :admin do
      resources :scheduled_actions, only: %i(index destroy)
      resources :scheduled_changes, only: %i(index destroy)
    end
  end
end
