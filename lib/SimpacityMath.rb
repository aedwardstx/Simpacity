#!/usr/bin/env ruby

#This is part of the Simpacity project
  

class SimpacityMath

  #Do the calculation and set the variables
  def initialize(sliceSize)
    @sliceSize = sliceSize
    @valuesLoaded=false
  end

  def loadValues(xvals, yvals)
    if self.arrayValuesCheck(xvals.length,yvals.length)
      @yvals = [] 
      @xvals = []
      #@yvals = yvals
      #@xvals = xvals
      yvals.each_with_index do |val, index|  #Not loading any yval 0 or below, not considering 0 as this would only likely occur during maintenance
        if val != 0
          @yvals << val
          @xvals << xvals[index]
        end
      end
      if @yvals.length > 0
        @valuesLoaded=true
        return true
      else
        self.trashEverything
        #handle this without aborting TODO
        abort "During a loadValues, all yvals were zero or there were no values in the array"
      end
    else
      #abort "Values were not loaded due to issue in arrayValuesCheck"
      return false
    end
  end

  def loadGroupValues(xvals, yvals, int_id)
    @groupMeasurements = [] if not defined?(@groupMeasurements)
    if self.arrayValuesCheck(xvals.length,yvals.length)
      yvals.each_with_index do |val, index|  #Not loading any yval 0 or below, not considering 0 as this would only likely occur during maintenance
        if val != 0
          @groupMeasurements << {'int_ids'=>[int_id],'time'=>xvals[index],'yval'=>val}
        end
      end
      return true
    else
      return false
    end
  end

  #Combine @groupMeasurements into a single group of xvals and yvals
  def aggregateGroupValues(window)
    if not defined? @groupMeasurements or @groupMeasurements.count == 0
      return false
    end
    sorted_measurements = @groupMeasurements.sort_by { |k| k["time"] }
    @groupMeasurements = nil
    measurements_window = []   # will hold a history of values with a time with in the window
    @xvals = [] #will hold aggregated X vals
    @yvals = [] #will hold aggregated Y vals

    #measurements_remap = {key=>combine_with}
    sorted_measurements.each do |sm_element|
      #pop old entries from the measurements_window to the aggregated_measurements array
      match_found = false
      measurements_window.delete_if do |mw_element|
        delete_the_current_mw_element = false
        if mw_element['time'] < sm_element['time'] - window
          @xvals << mw_element['time']
          @yvals << mw_element['yval']
          delete_the_current_mw_element = true
        end
        if not (delete_the_current_mw_element) and not (match_found) and not (mw_element['int_ids'].include? sm_element['int_ids'][0])
          mw_element['int_ids'] << sm_element['int_ids'][0]
          mw_element['yval'] += sm_element['yval']
          match_found = true
        end
        #puts mw_element.inspect
        #puts delete_the_current_mw_element.inspect
        delete_the_current_mw_element  #triggers the delete_if to delete the array element if true
      end

      #sm_entry could not be aggregated with a mw_entry, add it to the measurements window
      if not match_found
        measurements_window << sm_element
      end
    end

    #pop the remaining elements of the measurements_window into the aggregated_measurements data structure
    measurements_window.each do |mw_element|
      @xvals << mw_element['time']
      @yvals << mw_element['yval']
    end
    if (@xvals.length > 0) and (@yvals.length > 0)
      @valuesLoaded=true
      return true 
    end
  end

  def getRawVals
    return @xvals, @yvals
  end

  def arrayValuesCheck(xvalsLength,yvalsLength)
    if not xvalsLength==yvalsLength
      #abort("The X and Y array lengths are not the same!")
      return false
    elsif xvalsLength==0
      #abort("The X and Y array lengths are zero!")
      return false
    else
      return true
    end
  end

  def valuesLoaded
    return @valuesLoaded
  end

  def trashEverything
    @yvals = nil
    @xvals = nil
    self.trashFindings
    @valuesLoaded=false
  end

  def trashFindings
    @slope=nil
    @intercept=nil
    @y = nil
  end


  def findSIForPercentile(percentile) 
    aggYs = Array.new
    aggXs = Array.new

    #find the per-sliceSize percentile averages
    @yvals.each_slice(@sliceSize) do | batch |
      #puts "Here! #{batch.sort[-percentile..-1]}"
      #In order to keep the sort target from returning nil, have to handle the percentile averaging differently 
      if batch.size < percentile #percentile is larger than batch
        aggYs << batch.inject{ |sum, element| sum + element }.to_f / batch.size
      else #percentile is less than or equal to batch.length
        aggYs << batch.sort[-percentile..-1].inject{ |sum, element| sum + element }.to_f / percentile
      end
    end
    @xvals.each_slice(@sliceSize) do | batch |
      aggXs << batch.inject{ |sum, element| sum + element }.to_f / batch.size
    end
   
    #prepare some vabiables
    sumx=0.0; sumy=0.0; sumxy=0.0;sumsqrx=0.0
    xyLength = aggXs.length
    @slope = nil
    @intercept = nil
    if xyLength==1
      @slope = 0
      @intercept = aggYs[0]
      return @slope, @intercept
    else
      #prepare base calculations
      aggXs.each_with_index do |aggX, index|
        curxval = aggX.to_f
        curyval = aggYs[index].to_f
        xyval=curxval*curyval
        sqrx=curxval*curxval
        sumx=curxval+sumx
        sumy=curyval+sumy
        sumxy=xyval+sumxy
        sumsqrx=sqrx+sumsqrx
      end
      #calculate slope and intercept
      @slope=((xyLength*sumxy)-(sumx*sumy))/((xyLength*sumsqrx)-(sumx*sumx))
      @intercept=((sumy*sumsqrx)-(sumx*sumxy))/((xyLength*sumsqrx)-(sumx*sumx))
      return @slope, @intercept
    end
  end

  #Find and return Y given X
  def getYGivenX(x)
    @y=@slope*x+@intercept
    return @y.to_i
  end

  def getAverageRate
    sum_of_yvals = 0
    @yvals.each do |y|
      sum_of_yvals += y
    end
    @averageRate = (sum_of_yvals / @yvals.length)
    return @averageRate
  end

  #Will find the projected time in epoch when bandwidth will exceed watermark*bandwith
  #   The max time is controlled by maxProjectedTimeDistance, it is added to the largest xvals value to get the desired effect
  def projectDepletion(watermark, bandwidth, percentile, maxProjectedTimeDistance)

    #given bandwidth of y and highWatermark, find X value for depletion
    if self.valuesLoaded
      targetBandwidth=(bandwidth*watermark).to_i
      self.findSIForPercentile(percentile)
      lastSampleTime=@xvals.sort[-1]
      maxProjectedTimeDistance+=lastSampleTime
      #if the slope is 0, set to maxProjectedTimeDistance, else, do the time calculation
      if @slope == 0
        time=maxProjectedTimeDistance
      else
        time=((targetBandwidth-@intercept)/@slope).to_i
      end
      
      #Find out if the bandwidth has already been exceeded
      tb_exceeded = false
      tb_exceeded = true if (getYGivenX(lastSampleTime) >= targetBandwidth)

      #puts "Debug watermark=#{watermark},bandwidth=#{bandwidth},percentile=#{percentile},slope=#{@slope},intercept=#{@intercept},tb_exceeded=#{tb_exceeded}"
      #puts "Debug maxProjectedTimeDistance=#{maxProjectedTimeDistance},targetBandwidth=#{targetBandwidth},maxProjectedTimeDistance=#{maxProjectedTimeDistance},time=#{time}"
      
      #The link is not already exceeded will be exhausted sometime between now and maxProjectedTimeDistance
      if (tb_exceeded == false and time >= lastSampleTime and time <= maxProjectedTimeDistance)   #time is beween 0 and maxProjectedTimeDistance
        timeProjection = time

      #The link is not already exhausted and the projected exhaustion is before lastSampleTime(- slope) or beyound maxProjectedTimeDistance(+ slope)
      elsif ( tb_exceeded == false and (time < lastSampleTime or time > maxProjectedTimeDistance))  
        timeProjection = maxProjectedTimeDistance

      #The link has already been exhausted -- set the timeProjection to lastSampleTime
      elsif ( tb_exceeded == true )   
        timeProjection = lastSampleTime

      else
        abort "Not sure what happened, this is impossible"
      end
      return timeProjection.ceil #return the ceil as this value is in seconds
    else
      abort "No values loaded"
    end
  end
end

