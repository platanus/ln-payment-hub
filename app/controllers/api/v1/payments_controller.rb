require 'rpc_services_pb'
require 'rpc_pb'
require 'grpc'
require 'json'

class Api::V1::PaymentsController < ApplicationController
  include LightningHelper
  respond_to :json
  skip_before_action :verify_authenticity_token

  def create_invoice
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
    amount = get_amount_from_invoice(pay_req)
    payment_response = handle_invoice(user, amount, pay_req)
    create_payment_if_possible(amount, user, payment_response)
    response = JSON.parse('{"pay_req": { "payment_error":"'"#{payment_response}"'"}}')
    render json: response, status: 201
  end

  private

  def payment_params
    params.require(:payment).permit(:amount, :user, :pay_req)
  end

  def create_payment_if_possible(amount, slack_id, payment_response)
    return unless ['', nil].include? payment_response
    Payment.create(amount: -amount, user: User.find_by(slack_id: slack_id), status: 1)
  end

  def generate_payment_request(user, amount)
    request = Lnrpc::Invoice.new(value: amount, memo: user)
    client = LightningService.new
    client.stub.add_invoice(request).payment_request
  end

  def user_registered?(slack_id)
    User.find_by(slack_id: slack_id) != nil
  end

  def has_user_available_funds?(user, amount)
    #TODO: include transaction fee.
    User.find_by(slack_id: user).available_balance >= amount
  end

  def pay_payment_request(pay_req)
    #TODO: include transaction fee.
    send_payment(pay_req)
  end

  def pay_if_has_available_funds(user, amount, invoice)
    has_user_available_funds?(user, amount) ? pay_payment_request(invoice) : 'Not enough funds'
  end

  def handle_invoice(user, amount, invoice)
    user_registered?(user) ? pay_if_has_available_funds(user, amount, invoice) : 'User not registered'
  end
end
