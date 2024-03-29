Hangouts::Application.routes.draw do
  get "ratings/show"
  get "chat/show"
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
  put 'match/accept' => 'match#accept', as: :match_accept
  put 'match/reject' => 'match#reject', as: :match_reject

  get 'chat' => 'chat#show', as: :chat
  put 'chat/leave' => 'chat#leave', as: :chat_leave
  post 'chat/closed' => 'chat#closed', as: :chat_closed

  get 'ratings' => 'ratings#show', as: :ratings

  root :to => 'session#show'

  resources :users
  ActiveAdmin.routes(self)

  authpwn_session
  config_vars
end
