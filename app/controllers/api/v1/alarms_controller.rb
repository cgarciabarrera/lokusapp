class Api::V1::AlarmsController < Api::V1::CommonController

  before_action :set_user

  skip_before_filter :verify_authenticity_token

  def add_alarm_proximity_point

    #

    if params[:name].present? && params[:lat].present? && params[:lon].present? && params[:radius].present?

      #Location.where(:name => params[:name], :user_id => @user).destroy_all

      l = Location.new
      l.name=params[:name]
      l.lat=params[:lat]
      l.lon=params[:lon]
      l.radius=params[:radius]
      l.user_id = @user

      if l.valid?
        l.save
        api_ok(:id=>l.id)

      else
        api_error( l.errors, 500)
      end
    else
      api_error("missing fields", 404)
    end

  end


  def del_alarm

    if params[:id].present?

      l = Location.where(:id => params[:id], :user_id => @user)

      if l.present?
        l.first.destroy

        api_ok(:deleted =>true)
      else
        api_error("Locations not yours", 404)
      end

    else
      api_error("missing fields", 404)
    end

  end

  def list_alarms
    l = Location.where(:user_id => @user).select([:lat, :lon, :name, :radius, :id])
    api_ok(:locations=>l)

  end

end