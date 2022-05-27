require 'sidekiq/web'
require 'sidekiq-scheduler/web'
require 'sidekiq-status/web'

class SidekiqConstraint
  def matches?(request)
    JwtAuthorizer.find_user(request.session[:jwt]).present?
  end
end

Rails.application.routes.draw do
  root "home#index"

  mount Sidekiq::Web => '/sidekiq', constraints: SidekiqConstraint.new
  mount ActionCable.server => '/cable'

  resources :home, only: %i[index show]

  resources :users, only: [] do
    collection do
      post :login
      post :logout
    end
  end
end
