class SnmpsController < ApplicationController
  before_action :set_snmp, only: [:show, :edit, :update, :destroy]

  # GET /snmps
  def index
    @snmps = Snmp.all
  end

  # GET /snmps/1
  #def show
  #end

  # GET /snmps/new
  def new
    @snmp = Snmp.new
  end

  # GET /snmps/1/edit
  def edit
  end

  # POST /snmps
  def create
    @snmp = Snmp.new(snmp_params)

    respond_to do |format|
      if @snmp.save
        format.html { redirect_to snmps_url, notice: 'Snmp was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /snmps/1
  def update
    respond_to do |format|
      if @snmp.update(snmp_params)
        format.html { redirect_to snmps_url, notice: 'Snmp was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /snmps/1
  def destroy
    @snmp.destroy
    respond_to do |format|
      format.html { redirect_to snmps_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_snmp
      @snmp = Snmp.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def snmp_params
      params.require(:snmp).permit(:name, :default_community, :community_string)
    end
end
