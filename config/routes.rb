Store::Application.routes.draw do

  devise_for :users

  # match '/' => 'home#show', :via => :get, :as => :root
  root :to => 'home#show'

  resources :messages
  namespace :address do
      resource :billing, :controller => :billing
      resource :shipping, :controller => :shipping
  end

  namespace :admin do
    resources :products
    resource :product_search, :only => [:create, :show]
    resources :categories
    resources :users, :only => :index
    resources :orders
    resources :photos, :except => [:show]
    resources :product_families do
      collection do
        get :paginate
        post :search
      end
    end
    resources :product_attributes do
      collection do
        get :paginate
        post :search
      end
    end
  end

  match '/admin/home' => 'admin/home#index', :as => :admin_home, :via => :get
  match '/admin' => 'admin/home#index', :as => :admin, :via => :get
  match '/cart' => 'cart#show', :as => :current_cart, :id => 'current', :via => :get
  match '/empty_cart' => 'cart#destroy', :as => :empty_cart, :id => 'current', :via => :delete
  match '/update_cart' => 'cart#update', :as => :update_cart, :id => 'current', :via => :post
  match '/bootstrap' => 'admin/home#bootstrap', :as => :bootstrap, :via => :get

  scope :protocol => 'https', :controller => 'paypal/notifications' do
    match '/paypal/notify', :action => 'notify', :as => 'paypal_instant_payment'
    match '/paypal/update', :action  => 'update', :as => 'paypal_instant_update'
  end

  scope :protocol => 'https', :controller => 'paypal/express', 
    :method => :post, :host => 'phobos.thirdmode.com' do
    match '/paypal/express/setup', :action => 'setup', :as => 'paypal_express_setup'
    match '/paypal/express/purchase', :action  => 'purchase', :as => 'paypal_express_purchase'
    match '/paypal/express/cancel', :action => 'cancel', :as => 'paypal_express_cancel'
  end

  scope :protocol => 'https', :controller => 'paypal/direct', 
    :host => 'phobos.thirdmode.com', :method => :post do
    match '/paypal/direct/setup', :action => 'setup', :as => 'paypal/direct_setup'
    match '/paypal/direct/payment', :action => 'payment', :as => 'paypal/direct_payment'
  end    

  scope :protocol => 'https', :controller => 'paypal/nvp_api', 
    :host => 'phobos.thirdmode.com', :method => :post do
    match '/paypal/nvp_api/capture', :action => 'capture', :as => 'paypal/capture'
    match '/paypal/nvp_api/authorize', :action => 'authorize', :as => 'paypal/authorize'
    match '/paypal/nvp_api/reauthorize', :action => 'reauthorize', :as => 'paypal/reauthorize'
    match '/paypal/nvp_api/void', :action => 'void', :as => 'paypal/void'
  end    

  # This a redirect back to our website from PayPal.
  match '/paypal/express/confirm' => 'paypal/express#confirm',
    :as => :paypal_express_confirm, :protocol => 'https', :method => :get

  # This is a optional return from PayPal for PayPal standard.
  match '/paypal/standard/continue' => 'paypal/standard#continue_shopping',
    :as => :paypal_standard_continue, :protocol => 'https', :method => :get

  match '/braintree/notify' => 'gateway/braintree#notify',
    :as => :braintree_notify
  match '/braintree/create' => 'gateway/braintree#create',
    :as => :braintree_direct_post, :protocol => 'https', :only_path => false

  resources :order_transactions
  resources :line_items

  resources :products do
    collection do
      get :paginate
    end
  end

  # User can't destroy an order, only cancel it.
  resources :orders, :except => :create

  resources :users
  resources :photos, :only => [:show]
  resource :account, :controller => "users"
  resource :shipping_method, :controller => :shipping_method, :only => [:new, :create]

end
