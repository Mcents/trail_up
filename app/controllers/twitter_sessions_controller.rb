class TwitterSessionsController < ApplicationController
  def create
    user = User.from_twitter_omniauth(request.env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_path
  end
end
