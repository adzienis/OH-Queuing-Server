class LandingController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    redirect_to user_enrollments_path if current_user && user_signed_in?
  end
end
