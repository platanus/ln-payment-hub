class Api::V1::UsersController < ApplicationController
  respond_to :json
  skip_before_action :verify_authenticity_token

  def show
    respond_with User.find(params[:id])
  end

  def balance
    # TODO: Check if user exists.
    slack_id = params[:user]
    user = User.find_by(slack_id: slack_id)
    response = JSON.parse('{"user":
                          {
                            "balance":"'"#{user.available_balance}"'"
                            }}')

    render json: response, status: 201
  end

  def create
    user = User.new
    user.slack_id = params[:slack_id]
    user.email = params[:email]
    if user.save
      response = JSON.parse('{"user":
                          {
                            "error":"",
                            "email":"'"#{user.email}"'"
                            }}')

      render json: response, status: 201
    else
      errors = user.errors.full_messages
      response = JSON.parse('{"user":
                          {
                            "error":"'"#{errors.join(", ")}"'",
                            "email":""
                            }}')
      render json: response, status: 202
    end
  end

  def index
    respond_with User.all
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
