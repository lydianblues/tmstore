Store::Application.routes.draw do

  devise_for :users

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

  match '/' => 'home#show', :via => :get, :as => :root
  match '/admin/home' => 'admin/home#index', :as => :admin_home, :via => :get
  match '/admin' => 'admin/home#index', :as => :admin, :via => :get
  match '/gateway/paypal_api' => 'gateway/paypal_api#invoke',
    :as => :paypal_api, :via => :post
  match '/paypal/notify' => 'gateway/paypal_callback#notify',
    :as => :paypal_instant_payment, :protocol => 'https'
  match '/paypal/update' => 'gateway/paypal_callback#update',
    :as => :paypal_instant_update, :protocol => 'https'
  match '/paypal/express_payment' => 'gateway/paypal_express#purchase',
    :as => :paypal_express_complete, :protocol => 'https'
  match '/paypal/express_confirm' => 'gateway/paypal_express#confirm',
    :as => :paypal_express_confirm, :protocol => 'https'
  match '/paypal/express_cancel' => 'gateway/paypal_express#cancel',
    :as => :paypal_express_cancel, :protocol => 'https'
  match '/paypal/express_setup' => 'gateway/paypal_express#setup',
    :as => :paypal_express_setup, :protocol => 'https'
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

  match 'cart' => 'cart#show', :as => :current_cart, :id => 'current', :via => :get
  match 'empty_cart' => 'cart#destroy', :as => :empty_cart, :id => 'current', :via => :delete
  match 'update_cart' => 'cart#update', :as => :update_cart, :id => 'current', :via => :post
  match 'bootstrap' => 'admin/home#bootstrap', :as => :bootstrap, :via => :get
end
