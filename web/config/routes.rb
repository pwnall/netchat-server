Hangouts::Application.routes.draw do
  get 'profile' => 'profile#show', as: :profile
  put 'profile/add_facebook' => 'profile#add_facebook',
      as: :profile_add_facebook
  put 'profile/add_linkedin' => 'profile#add_linkedin',
      as: :profile_add_linkedin

  get 'queue' => 'queue#show', as: :queue
  put 'queue/enter' => 'queue#enter', as: :queue_enter
  put 'queue/leave' => 'queue#leave', as: :queue_leave
  post 'queue/matched' => 'queue#matched', as: :queue_matched

  get 'match' => 'match#show', as: :match
  put 'match/accept', as: :match_accept
  put 'match/reject', as: :match_reject

  root :to => 'session#show'

  resources :users
  ActiveAdmin.routes(self)

  authpwn_session
  config_vars
end
