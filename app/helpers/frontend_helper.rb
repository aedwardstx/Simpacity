module FrontendHelper

  def get_perlink_chart()
    int_id = params[:int_id].to_i
    percentile = params[:percentile].to_f
    start_epoch = params[:start_epoch].to_i
    end_epoch = params[:end_epoch].to_i
    #TODO -- move get bandwidth to get_int_stats -- should I really do this?
    bandwidth = Interface.find(int_id).bandwidth
    watermark = params[:watermark].to_f
    @chart = {}
    ['ifInOctets', 'ifOutOctets'].each do |record|
      @chart[record] = {}
      @chart[record]['points'] = []
      @chart[record]['stats'] = {}
      (arrayOfX, arrayOfY) = get_int_measurements(int_id, percentile, record, start_epoch, end_epoch)
      arrayOfX.each_with_index do |element,index|
        @chart[record]['points'][index] = []
        @chart[record]['points'][index] << element.to_i * 1000
        @chart[record]['points'][index] << arrayOfY[index]
      end

      first_record_point_x = @chart[record]['points'][0][0] 
      last_record_point_x = @chart[record]['points'][-1][0]
      first_projection_point_x = first_record_point_x / 1000
      #TODO -- abstarct the number of future days to graph a projection into general settings
      last_projection_point_x = (last_record_point_x / 1000) + (84600 * 30)

      (projection,average_rate,projection_start,projection_end) = get_int_stats(int_id, percentile, record, first_projection_point_x, last_projection_point_x, watermark)
      @chart[record]['stats']['average_rate'] = [[first_record_point_x,average_rate],[last_record_point_x,average_rate]]
      @chart[record]['stats']['projection'] = [[first_projection_point_x * 1000,projection_start],[last_projection_point_x * 1000,projection_end]] 
      @chart['watermark'] = [[first_record_point_x,watermark * bandwidth],[last_projection_point_x * 1000,watermark * bandwidth]] 
    end
    respond_to do |format|
      format.json { render :json => @chart.to_json }
    end
  end

  def get_int_group_chart()
    int_group_id = params[:ig_id].to_i
    percentile = params[:percentile].to_f
    start_epoch = params[:start_epoch].to_i
    end_epoch = params[:end_epoch].to_i
    bandwidth = get_int_group_bandwidth(int_group_id) 
    watermark = params[:watermark].to_f
    @chart = {}
    ['ifInOctets', 'ifOutOctets'].each do |record|
      @chart[record] = {}
      @chart[record]['points'] = []
      @chart[record]['stats'] = {}
      (arrayOfX, arrayOfY) = get_int_group_measurements(int_group_id, percentile, record, start_epoch, end_epoch)
      arrayOfX.each_with_index do |element,index|
        @chart[record]['points'][index] = []
        @chart[record]['points'][index] << element.to_i * 1000
        @chart[record]['points'][index] << arrayOfY[index]
      end

      first_record_point_x = @chart[record]['points'][0][0] 
      last_record_point_x = @chart[record]['points'][-1][0]
      first_projection_point_x = first_record_point_x / 1000
      #TODO -- abstarct the number of future days to graph a projection into general settings
      last_projection_point_x = (last_record_point_x / 1000) + (84600 * 30)

      (projection,average_rate,projection_start,projection_end) = get_int_group_stats(int_group_id, percentile, record, first_projection_point_x, last_projection_point_x, watermark)
      @chart[record]['stats']['average_rate'] = [[first_record_point_x,average_rate],[last_record_point_x,average_rate]]
      @chart[record]['stats']['projection'] = [[first_projection_point_x * 1000,projection_start],[last_projection_point_x * 1000,projection_end]] 
      @chart['watermark'] = [[first_record_point_x,watermark * bandwidth],[last_projection_point_x * 1000,watermark * bandwidth]] 
    end
    respond_to do |format|
      format.json { render :json => @chart.to_json }
    end
  end

  def get_int_measurements(int_id, percentile, record, start_epoch, end_epoch)
    int = Interface.find(int_id)
    start_time = Time.at(start_epoch)
    end_time = Time.at(end_epoch)
    measureTemp = int.measurements.where(:collected_at => start_time..end_time, :percentile => percentile, :record => record).pluck(:collected_at, :gauge)
    times = []
    gauges = []
    measureTemp.each do |element|
      times << element[0].to_i
      gauges << element[1]
    end
    return times, gauges
  end

  def get_int_group_measurements(int_group_id, percentile, record, start_epoch, end_epoch)
    int_group = InterfaceGroup.find(int_group_id)
    start_time = Time.at(start_epoch)
    end_time = Time.at(end_epoch)
    measureTemp = int_group.srlg_measurement.where(:collected_at => start_time..end_time, :percentile => percentile, :record => record).pluck(:collected_at, :gauge)
    times = []
    gauges = []
    measureTemp.each do |element|
      times << element[0].to_i
      gauges << element[1]
    end
    return times, gauges
  end

  def get_int_stats(int_id, percentile, record, start_epoch, end_epoch, watermark)
    (arrayOfX, arrayOfY) =  get_int_measurements(int_id, percentile, record, start_epoch, end_epoch)
    calc = SimpacityMath.new(1)
    if calc.loadValues(arrayOfX, arrayOfY)
      interface = Interface.find(int_id)
      bandwidth = interface.bandwidth
      projection = calc.projectDepletion(watermark, bandwidth, percentile, (86400 * Setting.first.max_trending_future_days))
      projection = (projection - (Time.now.to_i)) / 86400 
      average_rate = calc.getAverageRate
      projection_start = calc.getYGivenX(start_epoch) 
      projection_end = calc.getYGivenX(end_epoch) 
      calc.trashEverything #trashes everything
    else
      projection = average_rate = projection_start = projection_end = 0
    end

    return projection, average_rate, projection_start, projection_end
  end

  def get_int_group_stats(int_group_id, percentile, record, start_epoch, end_epoch, watermark)
    (arrayOfX, arrayOfY) =  get_int_group_measurements(int_group_id, percentile, record, start_epoch, end_epoch)
    calc = SimpacityMath.new(1)
    if calc.loadValues(arrayOfX, arrayOfY)
      bandwidth = get_int_group_bandwidth(int_group_id)
      projection = calc.projectDepletion(watermark, bandwidth, percentile, (86400 * Setting.first.max_trending_future_days))
      projection = (projection - (Time.now.to_i)) / 86400 
      average_rate = calc.getAverageRate
      projection_start = calc.getYGivenX(start_epoch) 
      projection_end = calc.getYGivenX(end_epoch) 
      calc.trashEverything #trashes everything
    else
      projection = average_rate = projection_start = projection_end = 0
    end

    return projection, average_rate, projection_start, projection_end
  end

  def get_int_group_bandwidth(int_group_id)
    interface_group = InterfaceGroup.find(int_group_id)
    bandwidth = 0
    interface_group.interfaces.each { |int| bandwidth += int.bandwidth }
    return bandwidth
  end

  def get_all_int_data(start_epoch,end_epoch,watermark,percentile)
    def hash_with_default_hash
            Hash.new { |hash, key| hash[key] = hash_with_default_hash }
    end
    @charts = hash_with_default_hash

    Interface.all.each do |int|
      records = ['ifInOctets','ifOutOctets']
      @charts[int.id]['deviceHostname'] = int.device.hostname
      @charts[int.id]['interfaceName'] = int.name
      @charts[int.id]['bandwidth'] = int.bandwidth
      @charts[int.id]['interfaceLinkType'] = int.link_type.name
      records.each do |record|
        (projection, average_rate, projection_start, projection_end) = get_int_stats(int.id, percentile, record, start_epoch, end_epoch, watermark)
        @charts[int.id][record]['values']['projection'] = projection  
        @charts[int.id][record]['values']['average_rate'] = average_rate
      end
    end
    return @charts
  end

  def get_all_int_group_data(start_epoch,end_epoch,watermark,percentile)
    def hash_with_default_hash
            Hash.new { |hash, key| hash[key] = hash_with_default_hash }
    end
    @charts = hash_with_default_hash

    InterfaceGroup.all.each do |int_group|
      records = ['ifInOctets','ifOutOctets']
      @charts[int_group.id]['int_group_name'] = int_group.name
      @charts[int_group.id]['bandwidth'] = get_int_group_bandwidth(int_group.id)
      records.each do |record|
        (projection, average_rate, projection_start, projection_end) = get_int_group_stats(int_group.id, percentile, record, start_epoch, end_epoch, watermark)
        @charts[int_group.id][record]['values']['projection'] = projection  
        @charts[int_group.id][record]['values']['average_rate'] = average_rate
      end
    end
    return @charts
  end
end
