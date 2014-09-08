class DevicesController < ApplicationController
  before_action :set_device, only: [:show, :edit, :update, :destroy] #, :new_point, :new_point1]

  before_filter :authenticate_user!, :except => [:new_point, :new_point1]


  # GET /devices
  # GET /devices.json
  def index
    #@devices = Device.all
    @devices = Device.where("user_id = ?",current_user.id )
  end

  # GET /devices/1
  # GET /devices/1.json
  def show
  end

  # GET /devices/new
  def new
    @device = Device.new
  end

  # GET /devices/1/edit
  def edit
  end

  # POST /devices
  # POST /devices.json
  def create
    @device = Device.new(device_params)
    #@device.user = current_user
    respond_to do |format|
      if @device.save
        format.html { redirect_to @device, notice: 'Device was successfully created.' }
        format.json { render action: 'show', status: :created, location: @device }

      else
        format.html { render action: 'new' }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /devices/1
  # PATCH/PUT /devices/1.json
  def update

    #el imei NUNCA debe ser modificable.

    respond_to do |format|
      if @device.update(device_params)
        format.html { redirect_to @device, notice: 'Device was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /devices/1
  # DELETE /devices/1.json
  def destroy
    @device.destroy

    $redis.srem("u:" + self.user.id.to_s, self.imei.to_s)
    respond_to do |format|
      format.html { redirect_to devices_url }
      format.json { head :no_content }
    end
  end

  def new_point

    if params[:imei].present?

      imei= params[:imei]
      #fix_time = params[:datetime]

      user_id = $redis.hget(imei.to_s + ":d", "usr")

      if user_id.nil?
        render :text => ("KO imei no existe en redis")
        return
      end

      fix_time = params[:datetime]

      #p "diferencia: " + (fix_time.to_i - $redis.hget("d:" + imei.to_s, "tim").to_i).to_s

      #if  fix_time.to_i - $redis.hget("d:" + imei.to_s, "tim").to_i < 8
      #  render :text => ("Mucha prisa")
      #  return
      #end

      @did = imei

      t = DateTime.strptime(fix_time,'%s').strftime("%y%m%d%H")

      #gps_data = "{:l => 2, :LN => 3, :tm => " + Time.now.to_f.to_s + "}"

      #datos del punto

      lat = params[:latitude]
      lon = params[:longitude]
      speed = params[:speed]
      altitude= params[:altitude]
      course = params[:course]

      extended=params[:extended]
      accuracy = "0"

      gps_data = ["lat", lat, "lon", lon, "spd", speed, "alt", altitude, "tim", fix_time, "crs", course, "ext", extended]

      gps_data_json = {:lat => lat, :lon=> lon, :spd => speed, :alt => altitude, :tim => fix_time, :crs => course, :ext => extended}.to_json


      $redis.hmset(imei + ":d", gps_data)
      #$redis.hset("d:" + imei, "lon", lon)
      #$redis.hset("d:" + imei, "spd", speed)
      #$redis.hset("d:" + imei, "alt", altitude)
      #$redis.hset("d:" + imei, "crs", course)
      #$redis.hset("d:" + imei, "tim", fix_time)
      #$redis.hset("d:" + imei, "lon", lon)

      expire_time = 31536000 #en segundos

      keyHour = @did.to_s + ":h"
      keyData = @did.to_s + ":" +  t
      keyMinData = @did.to_s + ":m"

      #lista contenedora de horas con datos
      #modelo: id_device : YYYYMMDDhh



      if $redis.sadd(keyHour, t)
        #si no hay datos de esa hora en la coleccion de horas del dispositivo, entonces lo graba
        # leer lista-> smembers 1:h
        $redis.zadd(keyMinData, t, gps_data_json )         #Leer datos de dentro->   zrange 1:m 0 -1
      end
      #se lee con
      # smembers 1:h

      #lista contenedora de datos de un device una hora en concreto
      #modelo: id_device:YYYYMMDDhh orden  valor = gps data
      $redis.zadd(keyData, fix_time, gps_data_json)         #Leer contenido con : zrange 1:14082616 0 -1
      $redis.expire(keyData, expire_time)

      render :text => ("OK")

    else
      render :text => ("KO IMEI no es parametro")
    end
  end


  def new_ack

  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_device
    @device = Device.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def device_params
    params.require(:device).permit(:name, :user_id, :type_id, :last_lat, :last_lon, :last_fix, :active, :available, :imei)
  end




end
