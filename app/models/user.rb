# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  uid             :string           not null
#  email           :string           not null
#  password_digest :string           not null
#  confirmed_at    :datetime
#

class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true, length: { minimum: 3, maximum: 64 }
  validates :password, presence: true, length: { minimum: 8 }

  before_validation { self[:uid] ||= SecureRandom.uuid }
end
