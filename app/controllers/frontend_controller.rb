class FrontendController < ApplicationController
  include FrontendHelper
#TODO
#a controller to export to CSV

  #TODO - generate data with default percentile, historical distance, and capacity watermark
  #def index
  #  redirect_to :controller=>'frontend', :action => 'per_link'
  #  #render :per_link
  #end

  # GET /frontend OR /frontend/per_link
  def per_link
    @post_var = Hash.new
    @post_var['watermark'] = params[:watermark].to_f || Setting.first.default_watermark
    @post_var['watermark'] = 1.00 if @post_var['watermark'] > 1
    @post_var['watermark'] = 0.40 if @post_var['watermark'] < 0.0001
    @post_var['percentile'] = params[:percentile] || Setting.first.default_percentile
    @post_var['percentile'] = @post_var['percentile'].to_i

    #if the user has posted to the form already
    if  params[:hd_from]
      start_time = Time.strptime(params[:hd_from], "%m/%d/%Y") 
    else
      start_time = Time.now - Setting.first.default_hist_dist.to_i.day
    end
    start_time = start_time.change(:hour => 0)
    start_epoch = start_time.to_i
    if params[:hd_to]
      end_time = Time.strptime(params[:hd_to], "%m/%d/%Y")
    else
      end_time = Time.now - 1.day 
    end
    end_time = end_time.change(:hour => 23, :min=> 59, :sec => 59)
    end_epoch = end_time.to_i 
   
    @post_var['hd_from'] =  start_time.strftime("%m/%d/%Y")
    @post_var['hd_to'] =  end_time.strftime("%m/%d/%Y")
    @post_var['start_epoch'] = start_epoch
    @post_var['end_epoch'] = end_epoch

    @charts = get_all_int_data(start_epoch,end_epoch,@post_var['watermark'],@post_var['percentile'])
    return @charts
    respond_to do |format|
      format.html
      #format.csv { send_data @products.to_csv }
      format.xls 
    end

  end

  def link_group
    @post_var = Hash.new
    @post_var['watermark'] = params[:watermark].to_f || Setting.first.default_watermark
    @post_var['watermark'] = 1.00 if @post_var['watermark'] > 1
    @post_var['watermark'] = 0.40 if @post_var['watermark'] < 0.0001
    @post_var['percentile'] = params[:percentile] || Setting.first.default_percentile
    @post_var['percentile'] = @post_var['percentile'].to_i

    #if the user has posted to the form already
    if  params[:hd_from]
      start_time = Time.strptime(params[:hd_from], "%m/%d/%Y") 
    else
      start_time = Time.now - Setting.first.default_hist_dist.to_i.day
    end
    start_time = start_time.change(:hour => 0)
    start_epoch = start_time.to_i
    if params[:hd_to]
      end_time = Time.strptime(params[:hd_to], "%m/%d/%Y")
    else
      end_time = Time.now - 1.day 
    end
    end_time = end_time.change(:hour => 23, :min=> 59, :sec => 59)
    end_epoch = end_time.to_i 
   
    @post_var['hd_from'] =  start_time.strftime("%m/%d/%Y")
    @post_var['hd_to'] =  end_time.strftime("%m/%d/%Y")
    @post_var['start_epoch'] = start_epoch
    @post_var['end_epoch'] = end_epoch

    @charts = get_all_int_data(start_epoch,end_epoch,@post_var['watermark'],@post_var['percentile'])
    return @charts
  end
  def export_per_link_stats
  end
  def export_per_link_data
  end
  def export_link_group_stats
  end
  def export_link_group_data
  end


  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def interface_params
      params.require(:frontend).permit(:watermark, :percentile, :hd_from, :hd_to)
    end

end
