module AuthenticationHelper
  include UsersHelper
  TOKEN = ENV['LND_API_TOKEN']
  def verify_token
    authenticate_or_request_with_http_token do |token|
      # Compare the tokens in a time-constant manner, to mitigate
      # timing attacks.
      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(token),
        ::Digest::SHA256.hexdigest(TOKEN)
      )
    end
  end

  def user_registered?
    User.find_by(slack_id: params[:user]).nil? ? handle_user_registration(params[:user]) : true
  end

  private

  def handle_user_registration(user)
    unless register_user(user)
      user_not_registered_response
    end
  end

  def user_not_registered_response
    response = JSON.parse(
      '{
          "error": {
            "errors": [{
              "domain": "global",
              "reason": "user_not_registered",
              "message": "The user is not registered"
            }],
          "code": "403",
          "message": "The user is not registered"
          }
    }')
    render json: response, status: 403
  end
end
