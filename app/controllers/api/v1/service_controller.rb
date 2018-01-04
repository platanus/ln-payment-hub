require 'rpc_services_pb'
require 'rpc_pb'
require 'grpc'
require 'json'

class Api::V1::ServiceController < ApplicationController
  include LightningHelper
  respond_to :json

  def lookup_invoice
    invoice = params[:invoice]
    pay_req = decode_invoice(invoice)
    response = JSON.parse('{"pay_req":
                            {
                              "num_satoshis":"'"#{pay_req.num_satoshis}"'",
                              "destination":"'"#{pay_req.destination}"'",
                              "description":"'"#{pay_req.description}"'"
                              }}')
    render json: response, status: 201
  end

end
