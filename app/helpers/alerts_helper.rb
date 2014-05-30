module AlertsHelper

  #include FrontendHelper

  def get_int_projection(int_id, percentile, noid, start_epoch, end_epoch, watermark, max_trending_future_days)
    (arrayOfX, arrayOfY) =  get_int_measurements(int_id, percentile, noid, start_epoch, end_epoch)
    calc = SimpacityMath.new(1)
    if calc.loadValues(arrayOfX, arrayOfY)
      interface = Interface.find(int_id)
      bandwidth = interface.bandwidth
      projection = calc.projectDepletion(watermark, bandwidth, percentile, (86400 * max_trending_future_days))
      projection = (projection - (Time.now.to_i)) / 86400
      calc.trashEverything #trashes everything
      return projection
    else
      return false
    end
  end

  def get_int_group_projection(int_group_id, percentile, noid, start_epoch, end_epoch, watermark, max_trending_future_days)
    (arrayOfX, arrayOfY) =  get_int_group_measurements(int_group_id, percentile, noid, start_epoch, end_epoch)
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

end
