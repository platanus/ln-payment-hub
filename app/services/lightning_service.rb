class LightningService < PowerTypes::Service.new

  def stub
    @stub ||= Lnrpc::Lightning::Stub.new(ENV['RPC_SERVER'], credentials)
  end

  private
  def credentials
    GRPC::Core::ChannelCredentials.new(File.read(ENV['TLS_CERT_PATH']))
  end

end
