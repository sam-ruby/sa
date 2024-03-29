Searchad::Application.routes.draw do

  get "help/index"

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for
  # RESTful applications.
  # Note: This route will make all actions in every controller accessible
  # via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  
  root :to => 'search_rel#index'
  #get 'search_quality_daily(/:action(.:format))'
  match 'search_rel(/:action(.:format))',
    :to => 'search_rel', :via => [:get, :post]  
  
  match 'poor_performing(/:action(.:format))',
    :to => 'poor_performing', :via => [:get, :post]  
  
  get 'ndcg(/:action(.:format))', :to=>'ndcg'
  get 'o_ndcg(/:action(.:format))', :to=>'o_ndcg'
  get 'conv_cor(/:action(.:format))', :to=>'conv_cor'
  get 'traffic(/:action(.:format))', :to=>'traffic'
  get 'pvr(/:action(.:format))', :to=>'pvr'
  get 'atc(/:action(.:format))', :to=>'atc'
  get 'conversion(/:action(.:format))', :to=>'conversion'
  get 'revenue(/:action(.:format))', :to=>'revenue'
  get 'oos(/:action(.:format))', :to=>'oos'
  get 'p1_oos(/:action(.:format))', :to=>'p1_oos'
  get 'release_notes(/:action(.:format))', :to=>'help'
  get 'comp_analysis(/:action(.:format))', :to=>'comp_analysis'
  get 'category(/:action(.:format))', :to=>'categories'
  get 'get_daily_change', :to=>'summary_metrics#get_daily_change'
  get 'get_overall_change', :to=>'summary_metrics#get_overall_change'
  get 'signal_comparison(/:action)', :to =>'signal_comparison'

  match 'search_kpi(/:action(.:format))',
    :to => 'search_k_p_i', :via => [:get, :post]  
  
  match 'search(/:action(.:format))',
    :to => 'search', :via => [:get, :post]

  match 'feedback(/:action(.:format))',
    :to => 'feedback', :via => [:get, :post]  
  
  namespace :monitoring do
    match 'count(/:action(.:format))',
      :to => 'count', :via => [:get, :post]
    match 'metrics(/:action(.:format))',
      :to => 'metrics', :via => [:get, :post]
  end
end
