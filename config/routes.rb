ActionController::Routing::Routes.draw do |map|
  ActionController::Routing::SEPARATORS <<  ";" unless ActionController::Routing::SEPARATORS.include?(";")


  map.resources :groups, :member => {:switch_public => :put, :switch_editable => :put}, :collection => { :autocomplete_for_user => :get, :autocomplete_for_groups => :get }
  map.resources :group_permissions, :member => { :switch_edit => :put, :switch_view => :put }
  map.resources :pages do |page|
    page.resources :page_parts do |page_part|
      page_part.resources :page_part_revisions
    end
  end
  
  map.connect 'dashboard/:action/:id', :controller => "dashboard"

  map.connect 'page/new', :controller => "page", :action => "create"

  map.page '*path;:action', :controller => "page"

  map.search 'search', :controller => 'page', :action => 'search'

  map.connect 'users/:action', :controller => "users"


  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  map.root :controller => 'page', :action => 'view', :path => []

  # See how all your routes lay out with "rake routes"
  map.page_view '*path' , :controller => 'page', :action => 'view'

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
