require 'rpc_services_pb'
require 'rpc_pb'
require 'grpc'
require 'json'

class Api::V1::ServiceController < ApplicationController
  include LightningHelper
  include PaymentsHelper
  include AuthenticationHelper
  respond_to :json
  before_action :verify_token

  def lookup_invoice
    invoice = params[:invoice]
    payment = Payment.find_by(pay_req: invoice)
    r_hash = payment.r_hash
    payment_success = lookup_db_invoice(payment)
    payment_success = lookup_ln_invoice(r_hash).settled unless payment_success
    response = JSON.parse('{"pay_req": { "status":"'"#{payment_success}"'" }}')
    render json: response
  end

  def decrypt_invoice
    invoice = params[:invoice]
    pay_req = decode_invoice(invoice)
    response = JSON.parse('{"pay_req":
                            {
                              "num_satoshis":"'"#{pay_req.num_satoshis}"'",
                              "destination":"'"#{pay_req.destination}"'",
                              "description":"'"#{pay_req.description}"'"
                              }}')
    render json: response
  end

  private

  def lookup_db_invoice(payment)
    payment.status == 'completed'
  end
end
