Simpacity::Application.routes.draw do
  devise_for :users
  resources :interface_autoconf_rules
  resources :device_autoconf_rules
  resources :alerts
  resources :contact_groups
  resources :link_types
  resources :settings
  resources :snmps
  resources :interface_groups
  resources :devices
  resources :interfaces
  resources :interface_bulks

  get '/frontend/get_int_group_chart', to: 'frontend#get_int_group_chart'
  post '/frontend/get_int_group_chart', to: 'frontend#get_int_group_chart'
  get '/frontend/get_perlink_chart', to: 'frontend#get_perlink_chart'
  post '/frontend/get_perlink_chart', to: 'frontend#get_perlink_chart'
  get '/frontend/per_link', to: 'frontend#per_link'
  post '/frontend/per_link', to: 'frontend#per_link'
  get '/frontend/link_group', to: 'frontend#link_group'
  post '/frontend/link_group', to: 'frontend#link_group'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  get '/frontend', to: redirect('/frontend/per_link')
  get '/', to: redirect('/frontend/per_link')
  #root 'frontend#per_link'

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
