Rails.application.routes.draw do
  resources :notifications
  namespace :admin , :as => :admin do
    get 'users' => 'user#users', :as => :users
    get 'index' => 'user#users'
    get '/' => 'user#users'
  end
  resources :transcoding_strategy_relationships
  resources :tags_relationships
  resources :tags
  resources :transcoding_strategies
  resources :transcodings
  namespace :advertise do
    resources :strategies
  end
  namespace :advertise do
    resources :resources
  end
  resources :players
  resources :logos

  get 'home/index'
  devise_for :accounts, controllers: { registrations: "user/registrations", sessions: 'user/sessions' }
  root 'home#index'
  # match ':controller/:action', :via => :all
  resources :user,  :as => :users do
    collection do
      get 'messages'
    end
  end

  resources :video_products do
    member do
      get 'download'
    end
  end
  resources :video_product_groups do
    member do
      get 'download'
    end
  end
  resources :video_product_group_check_statuses
  resources :user_videos do
    member do
      post 'republish'
      get 'clip'
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
