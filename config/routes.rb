Rails.application.routes.draw do
  scope path: '/api' do
    api_version(module: "Api::V1", path: { value: "v1" }, defaults: { format: 'json' }) do
      # Wallet.
      get   '/wallet/balance' => 'wallet#get_balance'

      # Services.
      get   '/service/lookup_invoice/:invoice' => 'service#lookup_invoice'
      get   '/service/decrypt_invoice/:invoice' => 'service#decrypt_invoice'

      # Users.
      get   '/users/:user/balance' => 'users#balance'
      post  '/users/create'    => 'users#create'
      post  '/get_user_status' => 'users#show'

      # Payments.
      get   '/payments/force_refresh/:user'     => 'payments#force_refresh'
      post  '/payments/create_invoice' => 'payments#create_invoice'
      post  '/payments/pay_invoice'    => 'payments#pay_invoice'
    end
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users
end
