class LightningService < PowerTypes::Service.new

  def stub
    @stub ||= Lnrpc::Lightning::Stub.new(Rails.configuration.tls_path, credentials)
  end

  private
  def credentials
    GRPC::Core::ChannelCredentials.new(File.read(Rails.configuration.rpc_server))
  end

end
