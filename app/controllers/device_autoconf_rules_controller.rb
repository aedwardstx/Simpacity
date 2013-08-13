class DeviceAutoconfRulesController < ApplicationController
  before_action :set_device_autoconf_rule, only: [:show, :edit, :update, :destroy]

  # GET /device_autoconf_rules
  def index
    @device_autoconf_rules = DeviceAutoconfRule.all
  end

  # GET /device_autoconf_rules/1
  #def show
  #end

  # GET /device_autoconf_rules/new
  def new
    @device_autoconf_rule = DeviceAutoconfRule.new
  end

  # GET /device_autoconf_rules/1/edit
  def edit
  end

  # POST /device_autoconf_rules
  def create
    @device_autoconf_rule = DeviceAutoconfRule.new(device_autoconf_rule_params)

    respond_to do |format|
      if @device_autoconf_rule.save
        format.html { redirect_to device_autoconf_rules_url, notice: 'Device autoconf rule was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /device_autoconf_rules/1
  def update
    respond_to do |format|
      if @device_autoconf_rule.update(device_autoconf_rule_params)
        format.html { redirect_to device_autoconf_rules_url, notice: 'Device autoconf rule was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /device_autoconf_rules/1
  def destroy
    @device_autoconf_rule.destroy
    respond_to do |format|
      format.html { redirect_to device_autoconf_rules_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device_autoconf_rule
      @device_autoconf_rule = DeviceAutoconfRule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_autoconf_rule_params
      params.require(:device_autoconf_rule).permit(:enabled, :network, :mask, :hostname_regex)
    end
end
