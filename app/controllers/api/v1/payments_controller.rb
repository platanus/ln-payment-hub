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
  INVOICE_EXPIRY = Integer(ENV['INVOICE_EXPIRY'])
  INVOICE_POOLING_TIME = Integer(ENV['INVOICE_POOLING_TIME'])

  def create_invoice
    user = params[:user]
    amount = Integer(params[:amount])
    invoice = generate_payment_request(user, amount, INVOICE_EXPIRY)
    pay_req = invoice.payment_request
    r_hash = to_hex_string(invoice.r_hash)
    response = JSON.parse('{"pay_req": "'"#{pay_req}"'", "status":"true"}')
    Payment.create(amount: amount,
                   user: User.find_by(slack_id: user), status: 2, pay_req: pay_req, r_hash: r_hash)
    CheckPendingInvoicesJob.set(wait: 4.second).perform_later r_hash, INVOICE_POOLING_TIME
    render json: response, status: 201
  end

  def pay_invoice
    user = params[:user]
    pay_req = params[:pay_req]
    amount = get_amount_from_invoice(pay_req)
    payment = Payment.create(user: User.find_by(slack_id: user),
                             pay_req: pay_req, amount: -amount, status: 0)
    payment_response = pay_if_has_available_balance(payment)
    payment_response == 'success' ? error = '' : error = payment_response
    fee = payment.fee
    destroy_unprocessed_payments(payment)
    balance = User.find_by(slack_id: user).available_balance
    response = JSON.parse('{"error":"'"#{error}"'", "balance":"'"#{balance}"'", "fee":"'"#{fee}"'"}')
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

  def destroy_unprocessed_payments(payment)
    if payment.status == "pending_outgoing"
      payment.destroy
    end
  end

  def has_user_available_balance?(payment)
    User.find(payment.user.id).available_balance + -payment.amount >= -payment.amount
  end

  def add_transaction_fee(response, payment)
    if response.payment_error.empty?
      payment.fee = Integer(response.payment_route.total_fees)
      payment.save
    end
  end

  def handle_payment(payment, destination_user)
    if User.find_by(slack_id: destination_user).nil?
      # Pay with LN.
      response = send_ln_payment(payment.pay_req)
      add_transaction_fee(response, payment)
      response.payment_error.empty? ? 'success' : 'Lightning Network error'
    else
      # Pay internally.
      response = send_internal_payment(payment, destination_user)
      response == 'success' ? 'success' : response
    end
  end

  def pay_payment_request(payment)
    decoded_invoice = decode_invoice(payment.pay_req)
    destination_user = decoded_invoice.description # TODO: Replace with invoice.
    response = handle_payment(payment, destination_user)
    response == 'success' ? complete_payment(payment) : response
  end

  def pay_if_has_available_balance(payment)
    has_user_available_balance?(payment) ? pay_payment_request(payment) : 'not_enough_funds'
  end
end
