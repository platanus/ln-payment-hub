Rails.application.routes.draw do
  scope path: '/api' do
    api_version(module: "Api::V1", path: { value: "v1" }, defaults: { format: 'json' }) do
      resources :users, :only => [:show, :index, :create]

      get   '/wallet_balance' => 'wallet#index'
      post  '/create_invoice' => 'payments#create'
      post  '/pay_invoice'    => 'payments#pay_invoice'
    end
  end
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users
end
