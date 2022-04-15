# frozen_string_literal: true

class UsersController < AuthorizedController
  skip_before_action :authorize, only: %i[login logout]
  before_action :reset_session, only: %i[login logout]

  def login
    token = JwtAuthorizer.create_token(email, password)

    if token.blank?
      head(:unauthorized)
      return
    end

    render json: { token: token }
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
