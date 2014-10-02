class DevicesController < ApplicationController
  before_action :set_device, only: [:show, :edit, :update, :destroy] #, :new_point, :new_point1]

  before_filter :authenticate_user!, :except => [:new_point, :new_point1]


  # GET /devices
  # GET /devices.json
  def index
    #@devices = Device.all
    @devices = Device.where("user_id = ?",current_user.id ).includes(:user)
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

    if params[:imei].present? && params[:datetime].present? && params[:latitude].present? && params[:longitude].present? && params[:speed].present? && params[:altitude].present? && params[:course].present? && params[:extended].present?
       if Device.new_point(params[:imei], params[:datetime], params[:latitude], params[:longitude], params[:speed], params[:altitude], params[:course], params[:extended])
          render :text => ("OK")
        else
          render :text => ("KO")
       end
    else
      render :text => ("KO")
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
