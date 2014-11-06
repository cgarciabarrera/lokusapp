class Api::V1::DevicesController < Api::V1::CommonController

  before_action :set_user, except: [:new_point]
  skip_before_filter :verify_authenticity_token



  def register_device
    if params[:imei].present? && params[:name].present? && params[:type_id]

      d =Device.new
      d.imei = params[:imei]
      d.name = params[:name]
      d.user_id = @user
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

    #if ENV['ALLOWED_IP'].include? request.remote_ip
    if true
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
      if imei_belongs_to_user?(params[:imei], @user )
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

  def device_last_points_by_interval

    if params[:end_time].present?
      end_time = DateTime.strptime(params[:end_time].to_s,'%s').strftime("%y%m%d%H")
      end_timestamp = params[:end_time].to_f

    else
      end_time = 0
    end

    if params[:start_time].present? && params[:imei].present?
      imei = params[:imei]
      #paso todo formato yymmddhh
      start_time = DateTime.strptime(params[:start_time].to_s,'%s').strftime("%y%m%d%H")
      start_timestamp = params[:start_time].to_f

      Device.hours_with_points(imei)


    else
      api_error("Missing params", 401)
    end

  end

  def device_last_points

    #recibe imei y cintidad de puntos

    if params[:points].present? && params[:imei].present?

      points_quantity = params[:points].to_i
      imei = params[:imei]

      if imei_belongs_to_user?(imei, @user) || imei_is_shared_to_user?(imei, @user)

        device =  Hash.new

        p = $redis.hgetall(imei + ":d")
        device["device_id"]=p["dev"]

        device["imei"] = imei

        device["lat"]=p["lat"].present? ? p["lat"] : nil
        device["lon"]=p["lon"].present? ? p["lon"] : nil
        device["tim"]=p["tim"].present? ? p["tim"] : nil
        if points_quantity > 1
          device[:last_points] = Device.last_x_points(imei, points_quantity)

        end

        api_ok(:device=>device)
      else
        api_error("Device not yours", 401)
      end

    else
      api_error("Missing params", 401)
    end

  end


  def list_own_devices


      points_quantity = 0
      if params[:points].present?

        points_quantity = params[:points].to_i
      end
      devices=[]
      device =  Hash.new
      $redis.smembers("u:" + @user.to_s).each do |q|

        p = $redis.hgetall(q + ":d")
        device["device_id"]=p["dev"]

        device["imei"] = q
        device["own"] = 1
        device["alarms"] = 0

        device["name"]=p["name"].present? ? p["name"] : nil
        device["lat"]=p["lat"].present? ? p["lat"] : nil
        device["lon"]=p["lon"].present? ? p["lon"] : nil
        device["tim"]=p["tim"].present? ? p["tim"] : nil
        if points_quantity > 1
          device[:last_points] = Device.last_x_points(q, points_quantity)

        end

        devices.push device.clone
        device.clear

      end

      #esto me da los compartidos

      $redis.smembers("us:" + @user.to_s).each do |q|

        p = $redis.hgetall(q + ":d")
        device["device_id"]=p["dev"]

        device["imei"] = q

        device["own"] = 0

        device["alarms"] = 0

        device["name"]=p["name"].present? ? p["name"] : nil
        device["lat"]=p["lat"].present? ? p["lat"] : nil
        device["lon"]=p["lon"].present? ? p["lon"] : nil
        device["tim"]=p["tim"].present? ? p["tim"] : nil
        if points_quantity > 1
          device[:last_points] = Device.last_x_points(q, points_quantity)

        end

        devices.push device.clone
        device.clear

      end



      api_ok(:devices=>devices)


  end

  def share_with
    #recibo device_id y email o nick de con quien comparto


    if params[:imei].present? && params[:email].present?


      imei = params[:imei]
      user_shared  = User.where("email = ?",params[:email])

      if user_shared.present?
        user_shared = user_shared.first

      else
        api_error("Error user",200)
        return
      end
      if @user == user_shared.id.to_s
        api_error("share with yourself not allowed", 200)
        return
      end
      if imei_belongs_to_user?(imei, @user)

        #borro lo existente antes que sea igual





        Device.share_with(imei, @user, user_shared.id)

        api_ok("OK")

      else
        api_error("Not belongs to you", 200)
      end
    else
      api_error("Missing params",200)
    end


  end


  def unshare
    #recibo device_id y email o nick de con quien comparto


    if params[:imei].present? && params[:email].present?


      imei = params[:imei]
      user_shared  = User.where("email = ?",params[:email])

      if user_shared.present?
        user_shared = user_shared.first

      else
        api_error("Error user",200)
        return
      end
      if @user == user_shared.id.to_s
        api_error("share with yourself not allowed", 200)
        return
      end
      if imei_belongs_to_user?(imei, @user)

        #borro lo existente antes que sea igual

        Device.unshare(imei, @user, user_shared.id)

        api_ok("OK")

      else
        api_error("Not belongs to you", 200)
      end
    else
      api_error("Missing params",200)
    end


  end

end