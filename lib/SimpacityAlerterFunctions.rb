


  def get_int_projection(int_id, percentile, record, start_epoch, end_epoch, watermark, max_trending_future_days)
    puts "here", int_id, percentile, record, start_epoch, end_epoch, watermark, max_trending_future_days
    (arrayOfX, arrayOfY) =  get_int_measurements(int_id, percentile, record, start_epoch, end_epoch)
    #puts arrayOfX, arrayOfY
    calc = SimpacityMath.new(1)
    if calc.loadValues(arrayOfX, arrayOfY)
      interface = Interface.find(int_id)
      bandwidth = interface.bandwidth
      projection = calc.projectDepletion(watermark, bandwidth, percentile, (86400 * max_trending_future_days))
      puts "The projection is: #{projection}"
      projection = (projection - Time.now.to_i) / 86400
      calc.trashEverything #trashes everything
      return projection
    else
      return false
    end
  end

  def get_int_group_projection(int_group_id, percentile, record, start_epoch, end_epoch, watermark, max_trending_future_days)
    (arrayOfX, arrayOfY) =  get_int_group_measurements(int_group_id, percentile, record, start_epoch, end_epoch)
    calc = SimpacityMath.new(1)
    if calc.loadValues(arrayOfX, arrayOfY)
      bandwidth = get_int_group_bandwidth(int_group_id)
      projection = calc.projectDepletion(watermark, bandwidth, percentile, (86400 * max_trending_future_days))
      projection = (projection - (Time.now.to_i)) / 86400
      calc.trashEverything #trashes everything
      return projection
    else
      return false
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

  def get_int_group_bandwidth(int_group_id)
    interface_group = InterfaceGroup.find(int_group_id)
    bandwidth = 0
    interface_group.interfaces.each { |int| bandwidth += int.bandwidth }
    return bandwidth
  end

