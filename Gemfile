# frozen_string_literal: true

source 'https://rubygems.org'

gem 'addressable'
gem 'aws-sdk-s3'
gem 'bcrypt'
gem 'bcrypt_pbkdf'
gem 'bencode'
gem 'chronic_duration'
gem 'cronex'
gem 'ed25519'
gem "ferrum"
gem 'filesize'
gem 'jbuilder'
gem 'jwt'
gem 'pg'
gem 'public_suffix'
gem 'puma'
gem 'rails'
gem 'redis'
gem 'redis-rails'
gem 'rexml'
gem 'sass-rails'
gem 'sendgrid-actionmailer'
gem 'sentry-rails'
gem "sentry-ruby"
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sidekiq-scheduler'
gem 'sidekiq-status'
gem 'turbolinks'
gem 'webpacker', '~> 6.0.0.beta.2'
gem 'xmlrpc'

group :default, :deploy, :development, :test do
  gem 'json'
  gem 'net-ssh', git: 'https://github.com/net-ssh/net-ssh.git', ref: 'a45f54fe1de434605af0b7195dd9a91bccd2cec5'
  gem 'parseconfig'
  gem 'pry'
  gem 'pry-remote'
  gem 'rest-client'
  gem 'yaml'
end

group :development do
  gem 'annotate'
  gem 'launchy'
  gem 'rubocop', '1.17.0'
  gem 'rubocop-rails', '2.11.3'
  gem 'ruby-prof'
  gem 'ruby-prof-flamegraph'
  gem 'web-console'
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'foreman'
  gem 'listen'
  gem 'mocha'
  gem 'qprof'
  gem 'webmock'
end
