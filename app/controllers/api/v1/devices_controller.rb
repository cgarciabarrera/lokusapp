class Api::V1::DevicesController < Api::V1::CommonController

  before_action :set_user, except: [:new_point]
  skip_before_filter :verify_authenticity_token



  def register_device
    if params[:imei].present? && params[:name].present? && params[:type_id]

      d =Device.new
      d.imei = params[:imei]
      d.name = params[:name]
      d.user = @user
      d.type_id = params[:type_id]
      d.active = true
      d.available = true
      if d.valid?
        d.save
        api_ok(:imei=>d.imei)


      else
        api_error(d.errors, 400)
      end
    else
      api_error("missing fields", 400)

    end


  end

  def new_point

    #########################
    ###                   ###
    ### no necesita token ###
    ###   es la llamada   ###
    ### desde java remoto ###
    ###                   ###
    #########################


    #solo dejarle si la api llama desde IP permitida

    if ENV['ALLOWED_IP'].include? request.remote_ip

      if params[:imei].present? && params[:datetime].present? && params[:latitude].present? && params[:longitude].present? && params[:speed].present? && params[:altitude].present? && params[:course].present? && params[:extended].present?

          if Device.new_point(params[:imei], params[:datetime], params[:latitude], params[:longitude], params[:speed], params[:altitude], params[:course], params[:extended])
            api_ok(:imei=>params[:imei])

          else
            api_error("error", 500)
          end

      else
          api_error("missing fields", 400)
      end
    else
      api_error("?", 401)

    end


  end

  def new_point_mobile

    #ver si el user tiene ese device

    if params[:imei].present? && params[:datetime].present? && params[:latitude].present? && params[:longitude].present? && params[:speed].present? && params[:altitude].present? && params[:course].present? && params[:extended].present?
      if imei_belongs_to_user?(params[:imei], @user.id )
        if Device.new_point(params[:imei], params[:datetime], params[:latitude], params[:longitude], params[:speed], params[:altitude], params[:course], params[:extended])
          api_ok(:imei=>params[:imei])

        else
          api_error("error", 500)
        end
      else
        api_error("Device not yours", 401)
      end

    else
      api_error("missing fields", 400)
    end
  end


  def list_own_devices
    ##currenuser devicesall json
    if @user.present?
      dato=[]
      punto=  Hash.new
      Device.mine(@user).each do |q|

        punto["device_id"]=q.id
        punto["imei"] = q.imei

          punto["lat"]=q.last_point.present? ? q.last_point[:lat] : nil
          punto["lon"]=q.last_point.present? ? q.last_point[:lon] : nil
          punto["tim"]=q.last_point.present? ? q.last_point[:tim] : nil

        dato.push punto.clone
        punto.clear

      end
      api_ok(:devices=>dato)

    end
  end



end