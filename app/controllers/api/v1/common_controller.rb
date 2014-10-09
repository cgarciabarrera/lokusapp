class Api::V1::CommonController < ApplicationController

  def api_error(message, status)
    render :json => {success: false, message: message}, status:  status
  end

  def api_ok(message)
    render :json => {success: true, message: message}, status: 200
  end

  def check_params

  end

  def set_user
    if params[:user_token].present?
      user = User.find_by_authentication_token(params[:user_token].to_s)
      if user
        @user = user
      else
        api_error("no user", 401)
      end
    else
      api_error("no user", 401)
    end
  end

  def imei_belongs_to_user?(imei, user_id)

    $redis.smembers("u:" + user_id.to_s).include? imei

  end




end