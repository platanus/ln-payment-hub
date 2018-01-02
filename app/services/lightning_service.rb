class LightningService < PowerTypes::Service.new

  def stub
    @stub ||= Lnrpc::Lightning::Stub.new(Rails.configuration.rpc_server, credentials)
  end

  private
  def credentials
    GRPC::Core::ChannelCredentials.new(File.read(Rails.configuration.tls_cert_path))
  end

end
