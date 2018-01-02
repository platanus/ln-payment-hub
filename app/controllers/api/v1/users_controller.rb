class Api::V1::UsersController < ApplicationController
  respond_to :json
  skip_before_action :verify_authenticity_token

  def show
    respond_with User.find(params[:id])
  end

  def create
    if User.find_by(slack_id: params[:slack_id])
      response = JSON.parse('{"user":
                            {
                              "error":"User already exist"
                              }}')
      render json: response, status: 202
    else
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
      end
    end
  end

  def index
    respond_with User.all
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :slack_id)
  end
end
