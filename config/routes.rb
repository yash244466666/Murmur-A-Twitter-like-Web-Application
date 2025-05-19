Rails.application.routes.draw do
  scope '/api-docs' do
    mount Rswag::Api::Engine => '/'
    mount Rswag::Ui::Engine => '/'
  end

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
    get 'profile/:username', to: 'users#profile'
    get 'profile/:username/murmurs', to: 'users#murmurs'
  end
end
