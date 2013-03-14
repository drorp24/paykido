Paykido::Application.routes.draw do

  devise_for :payers

  resources :rules do
    member do
      put 'stop', 'restart'
    end
  end 

  resources :statistics

  resources :tokens
  
  resources :allowances


  resources :purchases do
    resources :transactions
    member do
      get 'approve', 'decline'
    end
  end

#  resources :payers do
#    resources :consumers
#    resources :purchases do
#      resources :transactions
#    end
#    resources :rules
#    resources :notifications
#    resources :tokens
#  end

  resources :consumers do
    resources :consumers
    resources :rules
    resources :statistics
    resources :purchases do
      resources :transactions
    end
    member do
      get   'welcome'
      post  'confirm'
    end
  end

  match 'g2s/ppp/:status' => 'g2s#ppp_callback'
  match 'g2s/dmn/:status' => 'g2s#dmn'
#  match "/delayed_job" => DelayedJobWeb, :anchor => false
  
#  match 'login' => 'account#login', :as => :login

  match ':controller(/:action(/:id))'
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
   root :to => 'home#index'
   
     match "*a", :to => "home#routing_error", :as => "routing_error"


  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
