module LightningHelper
  def get_amount_from_invoice(invoice)
    decode_invoice(invoice).num_satoshis
  end

  def get_recipient_from_invoice(invoice)
    decode_invoice(invoice).description
  end

  def send_ln_payment(pay_req)
  request = Lnrpc::SendRequest.new(payment_request: pay_req)
  client = LightningService.new
  client.stub.send_payment_sync(request).payment_error
  end

  def decode_invoice(invoice)
    request = Lnrpc::PayReqString.new(pay_req: invoice)
    client = LightningService.new
    client.stub.decode_pay_req(request)
  end

  def lookup_ln_invoice(invoice)
    request = Lnrpc::PaymentHash.new(r_hash_str: invoice)
    client = LightningService.new
    client.stub.lookup_invoice(request)
  end

  def generate_payment_request(user, amount)
    request = Lnrpc::Invoice.new(value: amount, memo: user)
    client = LightningService.new
    client.stub.add_invoice(request)
  end

  def to_hex_string(bytes)
    bytes.unpack('H*').first
  end
end
