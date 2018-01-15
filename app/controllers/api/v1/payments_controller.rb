require 'rpc_services_pb'
require 'rpc_pb'
require 'grpc'
require 'json'

class Api::V1::PaymentsController < ApplicationController
  include LightningHelper
  include PaymentsHelper
  include AuthenticationHelper
  respond_to :json
  skip_before_action :verify_authenticity_token
  before_action :user_registered?
  before_action :verify_token
  INVOICE_EXPIRY_TIME = 180

  def create_invoice
    user = params[:user]
    amount = Integer(params[:amount])
    invoice = generate_payment_request(user, amount)
    pay_req = invoice.payment_request
    r_hash = to_hex_string(invoice.r_hash)
    response = JSON.parse('{"pay_req": "'"#{pay_req}"'", "status":"true"}')
    Payment.create(amount: amount,
                   user: User.find_by(slack_id: user), status: 2, pay_req: pay_req, r_hash: r_hash)
    CheckPendingInvoicesJob.set(wait: 4.second).perform_later r_hash, INVOICE_EXPIRY_TIME
    render json: response, status: 201
  end

  def pay_invoice
    # TODO: Create the Payment with status pending before LND handles it.
    user = params[:user]
    pay_req = params[:pay_req]
    amount = get_amount_from_invoice(pay_req)
    payment_response = pay_if_has_available_balance(user, amount, pay_req)
    payment_response == 'success' ? error = '' : error = payment_response
    balance = User.find_by(slack_id: user).available_balance
    response = JSON.parse('{"error":"'"#{error}"'", "balance":"'"#{balance}"'"}')
    render json: response, status: 201
  end

  def force_refresh
    user = params[:user]
    force_ln_refresh(user)
    response = JSON.parse('{"status": "true"}')
    render json: response, status: 201
  end

  private

  def payment_params
    params.require(:payment).permit(:amount, :user, :pay_req, :slack_id)
  end

  def has_user_available_balance?(user, amount)
    # TODO: include transaction fee.
    User.find_by(slack_id: user).available_balance >= amount
  end

  def handle_payment(pay_req, destination_user, user)
    if User.find_by(slack_id: destination_user).nil?
      # Pay with LN.
      response = send_ln_payment(pay_req)
      response.payment_error.empty? ? 'success' : 'Lightning Network error'
    else
      # Pay internally.
      response = send_internal_payment(pay_req, user)
      response == 'success' ? 'success' : response
    end
  end

  def pay_payment_request(pay_req, amount, user)
    # TODO: include transaction fee.
    decoded_invoice = decode_invoice(pay_req)
    destination_user = decoded_invoice.description
    response = handle_payment(pay_req, destination_user, user)
    response == 'success' ? create_payment(amount, user) : response
  end

  def pay_if_has_available_balance(user, amount, invoice)
    has_user_available_balance?(user, amount) ? pay_payment_request(invoice, amount, user) : 'not_enough_funds'
  end
end
