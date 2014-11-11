class Api::V1::LocationsController < Api::V1::CommonController

  before_action :set_user



  def add_location

    if params[:name].present? && params[:lat].present? && params[:lon].present? && params[:radius].present?
      #sleep 5
      u = User.new
      u.email = params[:email]
      u.password = params[:password]
      u.password_confirmation = params[:password]
      params[:nickname].present? ? u.name = params[:nickname] : params[:email]
      if u.valid?
        u.save
        api_ok(:auth_token=>u.authentication_token)

      else
        api_error( u.errors, 500)
      end
    else
      api_error("missing fields", 404)
    end

  end

end