require 'rpc_services_pb'
require 'rpc_pb'
require 'grpc'
require 'json'

class Api::V1::WalletController < ApplicationController
  include AuthenticationHelper
  before_action :authenticate

  respond_to :json

  def get_balance
    request = Lnrpc::WalletBalanceRequest.new(witness_only: true)
    client = LightningService.new
    response = client.stub.wallet_balance(request)
    response = JSON.parse('{"wallet_balance":
                            {
                              "total_balance":"'"#{response.total_balance}"'",
                              "confirmed_balance":"'"#{response.confirmed_balance}"'",
                              "unconfirmed_balance":"'"#{response.unconfirmed_balance}"'"
                              }}')
    respond_with response
  end
end
