class DevicesController < ApplicationController
  before_action :set_device, only: [:show, :edit, :update, :destroy, :new_point]

  before_filter :authenticate_user!


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
    respond_to do |format|
      format.html { redirect_to devices_url }
      format.json { head :no_content }
    end
  end

  def new_point
    a = Time.now.to_f
    cant = 100
    cant.times do
      t = Time.now.strftime("%y%m%d%H")
      gps_data = "{:l => 2, :LN => 3, :tm => " + Time.now.to_f.to_s + "}"
      expire_time = 365*24*60*60

      keyHour = @device.id.to_s + ":h"
      keyData = @device.id.to_s + ":" +  t
      keyMinData = @device.id.to_s + ":m"

      #lista contenedora de horas con datos
      #modelo: id_device : YYYYMMDDhh

      unless  $redis.sismember(keyHour, t)
        #no hay datos de esa hora en la coleccion de horas del dispositivo
        $redis.sadd(keyHour, t)                       # leer lista-> smembers 1:h
        $redis.zadd(keyMinData, t, gps_data )         #Leer datos de dentro->   zrange 1:m 0 -1
      end
      #se lee con
      # smembers 1:h

      #lista contenedora de datos de un device una hora en concreto
      #modelo: id_device:YYYYMMDDhh orden  valor = gps data
      $redis.zadd(keyData, t, gps_data.to_s)         #Leer contenido con : zrange 1:14082616 0 -1
      $redis.expire(keyData, expire_time)

    end
    b = Time.now.to_f

    render :text => (cant / (b - a)).to_s

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
      params.require(:device).permit(:name, :user_id, :type_id, :last_lat, :last_lon, :last_fix, :active, :available)
    end
end
