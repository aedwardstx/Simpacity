class LinkTypesController < ApplicationController
  before_action :set_link_type, only: [:show, :edit, :update, :destroy]

  # GET /link_types
  def index
    @link_types = LinkType.all
  end

  # GET /link_types/1
  def show
  end

  # GET /link_types/new
  def new
    @link_type = LinkType.new
  end

  # GET /link_types/1/edit
  def edit
  end

  # POST /link_types
  def create
    @link_type = LinkType.new(link_type_params)

    respond_to do |format|
      if @link_type.save
        format.html { redirect_to @link_type, notice: 'Link type was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /link_types/1
  def update
    respond_to do |format|
      if @link_type.update(link_type_params)
        format.html { redirect_to @link_type, notice: 'Link type was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /link_types/1
  def destroy
    @link_type.destroy
    respond_to do |format|
      format.html { redirect_to link_types_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_link_type
      @link_type = LinkType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def link_type_params
      params.require(:link_type).permit(:name, :description)
    end
end
