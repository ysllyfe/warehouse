Warehouse::Engine.routes.draw do
  resources :warehouses do
    resources :stocks, :only => [:index, :create]
    resources :goods,  :only => [:index, :create]
    resources :orders, :only => [:index, :show, :new, :create] do
      member do
        post 'memo', action: 'memo!'
      end
    end
    member do
      get 'merge'
      patch 'merge', action: 'merge!'
    end
  end
end