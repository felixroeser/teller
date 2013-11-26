require 'sidekiq/web'

Tellerapp::Application.routes.draw do

  resources :albums do
    resources :postings, controller: 'albums/postings' do
      resources :comments, controller: 'albums/postings/comments', only: [:new, :create]
    end
    # resources :postings, only: [:index, :show]
    resources :subscriptions, controller: 'albums/subscriptions', only: [:index, :destroy]
    resources :promotions, only: [:new, :create], controller: 'albums/promotions'
  end

  resources :feedbacks
  resources :subscriptions
  resources :postings
  resources :uploads
  resources :image_files do
    member do
      post 'rotate'
    end
  end

  # FIXME move under hooks
  resources :box_net_callbacks, only: [:create, :show]
  resources :box_net_auths, only: [:index]

  resources :invitations do
    member do
      get 'accept'
      post 'accepted'
      post 'rejected'
    end
  end

  get '/me', to: 'me#index'
  namespace 'me' do
    get :vcard
    resource :news, only: [:show] do
      resources :albums, only: [:show]
    end
  end

  namespace 'hooks' do
    resources :mandrill, only: [:create, :index]
  end

  namespace :admin do
    resources :feedbacks
    resources :comments

    resources :users
    resources :triggers, only: [:create], controller: 'admin/triggers'
    scope :info do
      get :news_gatherer, to: 'info#news_gatherer'
    end
  end

  devise_for :users, :controllers => { :registrations => "registrations" }
  root 'pages#home'

  # More static pages
  get '/about', to: 'pages#about'

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
