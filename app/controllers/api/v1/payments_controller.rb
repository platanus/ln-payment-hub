require 'rpc_services_pb'
require 'rpc_pb'
require 'grpc'
require 'json'

class Api::V1::PaymentsController < ApplicationController
  respond_to :json
  skip_before_action :verify_authenticity_token

  def create
    # TODO: Search for user into the DB.
    user = params[:user]
    amount = Integer(params[:amount])

    pay_req = generate_payment_request(user, amount)
    response = JSON.parse('{"pay_req": "'"#{pay_req}"'"}')
    render json: response, status: 201
  end

  def pay_invoice
    # TODO: Search for payment into the DB.
    user = params[:user]
    pay_req = params[:pay_req]
    pay_response = pay_payment_request(pay_req)

    response = JSON.parse('{"pay_req": "'"#{pay_response}"'"}')
    render json: response
  end

  private

  def payment_params
    params.require(:payment).permit(:amount, :user, :pay_req)
  end

  def generate_payment_request(user, amount)
    request = Lnrpc::Invoice.new(value: amount, memo: user)
    client = LightningService.new
    client.stub.add_invoice(request).payment_request
  end

  def pay_payment_request(pay_req)
    request = Lnrpc::SendRequest.new(payment_request: pay_req)
    client = LightningService.new
    client.stub.send_payment_sync(request)
  end


end
