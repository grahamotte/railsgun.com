module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = JwtAuthorizer.find_user(request.params[:jwt])
      reject_unauthorized_connection if current_user.blank?
    end
  end
end
