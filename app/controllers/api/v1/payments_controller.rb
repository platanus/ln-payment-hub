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
    """
    payment = Payment.new(user: user, amount: amount, pay_req: pay_req)
    if payment.save
      ##response
      render json: response, status: 201
    else
      render json: { errors: payment.errors }, status: 422
    end
    """
  end

  def pay_invoice
    # TODO: Search for payment into the DB.
    user = params[:user]


    pay_req = params[:pay_req]
    pay_response = pay_payment_request(pay_req)
    puts pay_response
    #response = JSON.parse('{"pay_req": "'"#{pay_req}"'"}')
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
    request = Lnrpc::SendPaymentSync.new(pay_req: pay_req)
    client = LightningService.new
    client.stub.pay_req_string(request)
  end


end
