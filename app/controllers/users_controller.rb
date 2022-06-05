class UsersController < ApplicationController
  before_action :reset_session

  def login
    token = JwtAuthorizer.create_token(email, password)

    if token.present?
      session[:jwt] = token
      render json: { token: token }
    else
      head :unauthorized
    end
  end

  def logout
    head :ok
  end

  private

  def email
    params.require(:email)
  end

  def password
    params.require(:password)
  end
end
