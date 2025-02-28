# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = authenticate_user
    end

    def request_var
      @request
    end

    private

    def authenticate_user
      if user = env["warden"].user
        user
      else
        reject_unauthorized_connection
      end
    end
  end
end
