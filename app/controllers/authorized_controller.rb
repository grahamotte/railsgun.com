# frozen_string_literal: true

class AuthorizedController < ApplicationController
  before_action :authorize

  private

  def authorize
    head :unauthorized if current_user.blank?
  end

  def current_user
    @current_user ||= begin
      ht = request.headers['Authorization']&.split&.last
      hu = JwtAuthorizer.find_user(ht)
      st = session[:jwt]
      su = JwtAuthorizer.find_user(st)

      if hu.present?
        session[:jwt] = ht
        hu
      elsif su
        su
      end
    end
  end
end
