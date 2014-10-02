class Api::V1::UsersController < Api::V1::CommonController

  before_action :set_user, except: [:register_user]

  skip_before_filter :verify_authenticity_token, :only => [:register_user]

  def register_user
    if params[:email].present? && params[:password].present?
      #sleep 5
      u = User.new
      u.email = params[:email]
      u.password = params[:password]
      u.password_confirmation = params[:password]
      params[:nickname].present? ? u.name = params[:nickname] : params[:email]
      if u.valid?
        u.save

        render :json=> {:success=>true, :auth_token=>u.authentication_token, :email=>u.email}
      else
        api_error( u.errors, 500)
      end
    else
        api_error("missing fields", 404)
    end

  end

end