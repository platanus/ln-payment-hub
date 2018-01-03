Rails.application.routes.draw do
  scope path: '/api' do
    api_version(module: "Api::V1", path: { value: "v1" }, defaults: { format: 'json' }) do
      resources :users, :only => [:show, :index, :create]

      get   '/wallet/balance' => 'wallet#get_balance'
      get   '/service/lookup_invoice/:invoice' => 'service#lookup_invoice'

      post  '/users/create'   => 'users#create'
      post  '/get_user_status' => 'users#show'

      post  '/payments/create_invoice' => 'payments#create'
      post  '/payments/pay_invoice'    => 'payments#pay_invoice'
    end
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users
end
