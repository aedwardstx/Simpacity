class InterfacesController < ApplicationController
  before_action :set_interface, only: [:show, :edit, :update, :destroy]
  
  # GET /interfaces
  def index
    @interfaces = Interface.all
    matches = []
    Interface.all.each do |int|
      match = true
      if params[:q]
        params[:q].split(/ /).each do |query|
          if not "#{int.device.hostname}_#{int.name}_#{int.link_type.name}" =~ /#{query}/i
            match = false 
          end
        end
      end
      matches << int.id if match == true
    end
    
    matching_ints = Interface.find_all_by_id(matches)
    #interfaces = Interface.where("name like ?", "%#{params[:q]}%")
    #devices = Interface.device.where("hostname like ?", "%#{params[:q]}%")
    respond_to do |format|
      format.html
      format.json { render :json => matching_ints.collect {|int| {:id => int.id, :name => "#{int.device.hostname}_#{int.name}_#{int.link_type.name}"}}}
    end
  end

  # GET /interfaces/1
  def show
  end

  # GET /interfaces/new
  def new
    @interface = Interface.new
  end

  # GET /interfaces/1/edit
  def edit
  end

  # POST /interfaces
  def create
    @interface = Interface.new(interface_params)

    respond_to do |format|
      if @interface.save
        format.html { redirect_to interfaces_url, notice: 'Interface was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /interfaces/1
  def update
    respond_to do |format|
      if @interface.update(interface_params)
        format.html { redirect_to interfaces_url, notice: 'Interface was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /interfaces/1
  def destroy
    @interface.destroy
    respond_to do |format|
      format.html { redirect_to interfaces_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_interface
      @interface = Interface.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def interface_params
      params.require(:interface).permit(:device_id, :link_type_id, :description, :name, :device_tokens, :bandwidth, :q)
    end
end
