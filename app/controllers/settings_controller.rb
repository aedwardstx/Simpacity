class SettingsController < ApplicationController
  before_action :set_setting, only: [:show, :edit, :update, :destroy]

  # GET /settings
  def index
    @setting = Setting.first
  end

  # GET /settings/1
  #def show
  #end

  # GET /settings/new
  #def new
  #  @setting = Setting.new
  #end

  # GET /settings/1/edit
  def edit
  end

  # POST /settings
  #def create
  #  @setting = Setting.new(setting_params)

  #  respond_to do |format|
  #    if @setting.save
  #      format.html { redirect_to @setting, notice: 'Setting was successfully created.' }
  #    else
  #      format.html { render action: 'new' }
  #    end
  #  end
  #end

  # PATCH/PUT /settings/1
  def update
    respond_to do |format|
      if @setting.update(setting_params)
        format.html { redirect_to settings_url, notice: 'Setting was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /settings/1
  def destroy
    @setting.destroy
    respond_to do |format|
      format.html { redirect_to settings_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_setting
      @setting = Setting.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def setting_params
      params.require(:setting).permit(:slice_size, :default_percentile, :default_watermark, :max_hist_dist, :default_hist_dist, 
                                      :zpoller_rc_location, :zconfig_location, :zpoller_hosts_location, :zpoller_base_dir, 
                                      :mongodb_test_window, :mongodb_db_hostname, :mongodb_db_port, :mongodb_db_name, 
                                      :link_group_importer_lookback_window, :zpoller_poller_interval, :mailhost, 
                                      :polling_interval_secs, :max_trending_future_days, :min_alert_measurements_percent,
                                      :min_bps_for_inclusion, :source_email_address, :average_previous_hours)
    end
end
