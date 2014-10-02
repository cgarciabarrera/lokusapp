class Api::V1::CommonController < ApplicationController

  def api_error(message, status)
    render :json => {success: false, message: message}, status:  status
  end

  def check_params

  end

  def set_user
    if params[:user_token].present?
      user = User.find_by_authentication_token(params[:user_token].to_s)
      if user
        @user = user
      else
        @user = false
      end
    else
      @user = false
    end
  end

end