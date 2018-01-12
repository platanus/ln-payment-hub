class Api::V1::UsersController < ApplicationController
  include AuthenticationHelper
  respond_to :json
  skip_before_action :verify_authenticity_token
  before_action :authenticate

  def show
    respond_with User.find(params[:id])
  end

  def balance
    # TODO: Check if user exists.
    slack_id = params[:user]
    user = User.find_by(slack_id: slack_id)
    response = JSON.parse('{"user": {
                              "balance":"'"#{user.available_balance}"'"
                            }}')

    render json: response, status: 200
  end

  def create
    user = User.new
    user.slack_id = params[:slack_id]
    user.email = params[:email]
    if user.save
      respond_successful_creation(user.email)
    else
      errors = user.errors.full_messages
      respond_error_creation(errors)
    end
  end

  def index
    respond_with User.all
  end

  private

  def respond_successful_creation(email)
    response = JSON.parse('{"user":
                                {
                                  "error":"",
                                  "email":"'"#{email}"'"
                                }
                             }')
    render json: response, status: 201
  end

  def respond_error_creation(errors)
    response = JSON.parse('{"user":
                          {
                            "error":"'"#{errors.join(', ')}"'",
                            "email":""
                            }}')
    render json: response, status: 202
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
