Hangouts::Application.routes.draw do
  get 'profile' => 'profile#show', as: :profile
  root :to => 'session#show'

  resources :users
  ActiveAdmin.routes(self)

  authpwn_session
  config_vars
end
