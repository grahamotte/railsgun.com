ENV['RAILS_ENV'] ||= 'test'
require_relative "../config/environment"
require "rails/test_help"
require 'minitest/unit'
require 'mocha/minitest'
require 'webmock/minitest'

WebMock.disable_net_connect!(allow_localhost: true)

class Secrets
  def method_missing(*, **)
    'lol_no'
  end

  def respond_to_missing?
    true
  end
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  setup do
    Rails.application.credentials = Secrets.new
    Rails.application.secrets = Secrets.new
    Rails.cache.clear
  end
end
