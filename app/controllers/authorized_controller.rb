# frozen_string_literal: true

class AuthorizedController < ApplicationController
  before_action :authorize

  private

  def authorize
    head :unauthorized if current_user.blank?
  end

  def current_user
    @current_user ||= begin
      token = session[:jwt] || request.headers['Authorization']&.split&.last
      session[:jwt] ||= token

      JwtAuthorizer.find_user(token)
    end
  end
end
