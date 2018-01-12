module AuthenticationHelper
  TOKEN = ENV['LND_API_TOKEN']
  def authenticate
    authenticate_or_request_with_http_token do |token|
      # Compare the tokens in a time-constant manner, to mitigate
      # timing attacks.
      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(token),
        ::Digest::SHA256.hexdigest(TOKEN)
      )
    end
  end
end
