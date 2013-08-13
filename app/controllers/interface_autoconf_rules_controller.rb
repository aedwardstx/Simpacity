class InterfaceAutoconfRulesController < ApplicationController
  before_action :set_interface_autoconf_rule, only: [:show, :edit, :update, :destroy]

  # GET /interface_autoconf_rules
  def index
    @interface_autoconf_rules = InterfaceAutoconfRule.all
  end

  # GET /interface_autoconf_rules/1
  #def show
  #end

  # GET /interface_autoconf_rules/new
  def new
    @interface_autoconf_rule = InterfaceAutoconfRule.new
  end

  # GET /interface_autoconf_rules/1/edit
  def edit
  end

  # POST /interface_autoconf_rules
  def create
    @interface_autoconf_rule = InterfaceAutoconfRule.new(interface_autoconf_rule_params)

    respond_to do |format|
      if @interface_autoconf_rule.save
        format.html { redirect_to interface_autoconf_rules_url, notice: 'Interface autoconf rule was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /interface_autoconf_rules/1
  def update
    respond_to do |format|
      if @interface_autoconf_rule.update(interface_autoconf_rule_params)
        format.html { redirect_to interface_autoconf_rules_url, notice: 'Interface autoconf rule was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /interface_autoconf_rules/1
  def destroy
    @interface_autoconf_rule.destroy
    respond_to do |format|
      format.html { redirect_to interface_autoconf_rules_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_interface_autoconf_rule
      @interface_autoconf_rule = InterfaceAutoconfRule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def interface_autoconf_rule_params
      params.require(:interface_autoconf_rule).permit(:enabled, :name_regex, :description_regex, :link_type_id)
    end
end
