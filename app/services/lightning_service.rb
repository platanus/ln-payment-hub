class LightningService < PowerTypes::Service.new

  def stub
    @stub ||= Lnrpc::Lightning::Stub.new('localhost:10009', credentials)
  end

  private
  def credentials
    GRPC::Core::ChannelCredentials.new(File.read('/Users/cristobal/Library/Application Support/Lnd/tls.cert'))
  end

end
