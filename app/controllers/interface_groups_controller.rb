class InterfaceGroupsController < ApplicationController
  before_action :set_interface_group, only: [:show, :edit, :update, :destroy]

  # GET /interface_groups
  def index
    @interface_groups = InterfaceGroup.all
  end

  # GET /interface_groups/1
  #def show
  #end

  # GET /interface_groups/new
  def new
    @interface_group = InterfaceGroup.new
  end

  # GET /interface_groups/1/edit
  def edit
  end

  # POST /interface_groups
  def create
    @interface_group = InterfaceGroup.new(interface_group_params)

    respond_to do |format|
      if @interface_group.save
        format.html { redirect_to '/interface_groups', notice: 'Interface group was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /interface_groups/1
  def update
    respond_to do |format|
      if @interface_group.update(interface_group_params)
        format.html { redirect_to '/interface_groups', notice: 'Interface group was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /interface_groups/1
  def destroy
    @interface_group.destroy
    respond_to do |format|
      format.html { redirect_to interface_groups_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_interface_group
      @interface_group = InterfaceGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def interface_group_params
      params.require(:interface_group).permit(:name, :description, :interface_tokens, :refresh_next_import)
    end
end
