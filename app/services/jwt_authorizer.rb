class JwtAuthorizer
  SECRET = Rails.application.secrets.secret_key_base.to_s

  class << self
    def create_token(email, password, exp: 14.days.from_now)
      user = User.find_by(email: email) || User.create(email: email, password: password)

      return if user.blank?
      return unless user.authenticate(password)

      JWT.encode({ user_id: user.id, email: user.email, exp: exp.to_i }, SECRET)
    end

    def find_user(token)
      JWT.decode(token, SECRET).first.then { |x| User.find(x['user_id']) }
    rescue StandardError
      nil
    end
  end
end
