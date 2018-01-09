class LightningService < PowerTypes::Service.new

  def stub
    @stub ||= Lnrpc::Lightning::Stub.new(ENV['RPC_SERVER'], credentials)
  end

  private
  def credentials
    GRPC::Core::ChannelCredentials.new(ENV['TLS_CERT'])
  end

end
