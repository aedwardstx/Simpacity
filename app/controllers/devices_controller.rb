class DevicesController < ApplicationController
  before_action :set_device, only: [:show, :edit, :update, :destroy]
  #include DeviceHelper

  # GET /devices
  def index
    #@devices = Device.all
    @devices = Device.where("hostname like ?", "%#{params[:q]}%")
    respond_to do |format|
      format.html
      #format.json { render :json => @devices.map(&:attributes) }
      format.json { render :json => @devices.collect {|device| {:id => device.id, :name => device.hostname}}}
    end

  end

  # GET /devices/1
  def show
  end

  # GET /devices/new
  def new
    @device = Device.new
  end

 # GET /devices/1/edit_many_ints_for_device
  def edit_many_ints_for_device
    #get a list of all ints from mongodb for the device
    #cross this list with interfaces that are already associated
    #return an instance variable
    #@interfaces_for_device = Device.all
  end

 # POST /devices/1/update_many_ints_for_device
  def update_many_ints_for_device
    
  end



  # GET /devices/1/edit
  def edit
  end

  # POST /devices
  def create
    @device = Device.new(device_params)

    respond_to do |format|
      if @device.save
        format.html { redirect_to devices_url, notice: 'Device was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /devices/1
  def update
    respond_to do |format|
      if @device.update(device_params)
        format.html { redirect_to devices_url, notice: 'Device was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /devices/1
  def destroy
    @device.destroy
    respond_to do |format|
      format.html { redirect_to devices_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = Device.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      params.require(:device).permit(:description, :hostname, :snmp_community, :snmp_id)
    end
end
