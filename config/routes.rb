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
  post 'users', to: 'users#create', as: :users # This is for web signup
  post 'signup', to: 'users#create' # This is also for web signup, as an alternative path

  # Web Routes
  resources :murmurs, only: [:create, :destroy] do
    resource :like, only: [:create, :destroy]
  end
  resources :follows, only: [:create, :destroy]
  
  # Timeline and user profiles
  get 'timeline', to: 'murmurs#timeline', as: :timeline
  get '@:username', to: 'users#profile', as: :profile
  get '@:username/followers', to: 'users#followers', as: :user_followers
  get '@:username/following', to: 'users#following', as: :user_following
  
  resources :follows, only: [:create, :destroy]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API Authentication routes
  scope '', defaults: { format: :json } do
    post 'auth/login', to: 'authentication#login'
    post 'users', to: 'users#create'
  end

  # API routes
  scope '/api', defaults: { format: :json } do
    # Murmurs endpoints
    get 'murmurs', to: 'murmurs#index'
    post 'murmurs', to: 'murmurs#create'
    delete 'murmurs/:id', to: 'murmurs#destroy'
    get 'murmurs/:id/detail', to: 'murmurs#detail'
    post 'murmurs/:id/like', to: 'likes#create'
    delete 'murmurs/:id/like', to: 'likes#destroy'

    # Timeline
    get 'timeline', to: 'murmurs#timeline'

    # User-specific endpoints
    get 'me/murmurs', to: 'murmurs#my_murmurs'
    
    # Follows and likes
    resources :follows, only: [:create, :destroy]
    resources :likes, only: [:create, :destroy]
    
    # Profile routes
    scope 'profile/:username' do
      get '/', to: 'users#profile'
      get '/followers', to: 'users#followers'
      get '/following', to: 'users#following'
    end
  end
end
