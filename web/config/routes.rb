Hangouts::Application.routes.draw do
  get 'profile' => 'profile#show', as: :profile
  put 'profile/add_facebook' => 'profile#add_facebook',
      as: :profile_add_facebook
  put 'profile/add_linkedin' => 'profile#add_linkedin',
      as: :profile_add_linkedin

  root :to => 'session#show'

  resources :users
  ActiveAdmin.routes(self)

  authpwn_session
  config_vars
end
