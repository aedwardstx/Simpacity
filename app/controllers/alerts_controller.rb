class AlertsController < ApplicationController
  before_action :set_alert, only: [:show, :edit, :update, :destroy]

  # GET /alerts
  def index
    @alerts = Alert.all
  end

  # GET /alerts/1
  #def show
  #end

  # GET /alerts/new
  def new
    @alert = Alert.new
  end

  # GET /alerts/1/edit
  def edit
  end

  # POST /alerts
  def create
    @alert = Alert.new(alert_params)

    respond_to do |format|
      if @alert.save
        format.html { redirect_to alerts_url, notice: 'Alert was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /alerts/1
  def update
    respond_to do |format|
      if @alert.update(alert_params)
        format.html { redirect_to alerts_url, notice: 'Alert was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /alerts/1
  def destroy
    @alert.destroy
    respond_to do |format|
      format.html { redirect_to alerts_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_alert
      @alert = Alert.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def alert_params
      params.require(:alert).permit(:enabled, :name, :description, :int_type, :link_type_id, :match_regex, :percentile, :watermark, :days_out, :contact_group_id, :days_back)
    end
end
