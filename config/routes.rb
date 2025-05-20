Rails.application.routes.draw do
  # Mount Swagger UI for API documentation
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'

  # Web Interface Routes
  root 'murmurs#timeline'
  
  # Authentication routes for web interface
  get 'login', to: 'authentication#login_form', as: :login
  post 'login', to: 'authentication#login'
  delete 'logout', to: 'authentication#logout', as: :logout
  get 'signup', to: 'users#new', as: :signup
  post 'signup', to: 'users#create'

  # Web Routes
  resources :murmurs, only: [:create, :destroy] do
    resource :like, only: [:create, :destroy]
  end
  
  get 'timeline', to: 'murmurs#timeline', as: :timeline
  get '@:username', to: 'users#profile', as: :profile
  resources :follows, only: [:create, :destroy]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication routes
  post 'auth/login', to: 'authentication#login'
  post 'users', to: 'users#create'

  # API routes
  scope '/api' do
    # Murmurs endpoints
    get 'murmurs', to: 'murmurs#index'
    get 'murmurs/:id/detail', to: 'murmurs#detail'
    
    # Personal murmurs endpoints
    scope 'me' do
      get 'murmurs', to: 'murmurs#my_murmurs'
      post 'murmurs', to: 'murmurs#create'
      delete 'murmurs/:id', to: 'murmurs#destroy'
    end
    
    # Social features
    resources :follows, only: [:create, :destroy]
    resources :likes, only: [:create, :destroy]
    
    # Timeline and profile
    get 'timeline', to: 'murmurs#timeline'

    scope 'profile/:username' do
      get '/', to: 'users#profile', as: :user_profile
      get '/murmurs', to: 'users#murmurs', as: :user_murmurs
      get '/followers', to: 'users#followers', as: :user_followers
      get '/following', to: 'users#following', as: :user_following
    end
  end
end
