Rails.application.routes.draw do
  root to: redirect('bounce_mails')

  match 'bounce_mails', to: 'bounce_mails#index', via: [:get, :post]
  resources :bounce_mails, only: [:show]

  post 'whitelist_mails/register', to: 'whitelist_mails#register'
  resources :whitelist_mails, only: [:index, :new, :create, :destroy]
end
