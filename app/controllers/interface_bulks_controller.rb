class InterfaceBulksController < ApplicationController
  include InterfaceBulksHelper
  #Flow
  #load all interfaces for device from AR into a data structure
  #load all ints for device from mongodb into a data structure 
  #render the page
  def edit
    device = Device.find(params[:id])
    hostname = device.hostname
    @bulk_ints = {'device_id' => device.id, 'device_hostname' => device.hostname}
    @bulk_ints['ints'] = []
    #get the ints from AR
    device.interfaces.each do |int|
      @bulk_ints['ints'] << {'int_id'=>int.id,'used'=>'yes','name'=>int.name,'link_type_id'=>int.link_type_id,'description'=>int.description,'bandwidth'=>int.bandwidth}
    end
    #get ints for device from mongodb, do not load something that was already loaded from AR
    get_interfaces_for_device(device.id).each do |int|
      #if not already in @bulk_ints and the interface name does not contain a period, which causes issues for int health check and importer for some reason
      if not @bulk_ints['ints'].any? {|h| h['name'] == int} 
        if int !~ /\./ and int !~ /dwdm/ and int !~ /Tu\d/ and int !~ /Lo\d/ and int !~ /Vo\d/ and int !~ /Nu\d/ and int !~ /Null\d/ and int !~ /Mgmt/ and int !~ /Loop/ and int !~ /GM0/ and int !~ /Gi0$/ and int !~ /tunnel/
          (bandwidth,description) = get_interface_metadata_by_name(hostname,int)
          @bulk_ints['ints'] << {'int_id'=>nil,'used'=>'no','name'=>int,'link_type'=>nil,'description'=>description,'bandwidth'=>bandwidth}
        end
      end  
    end
  end

  # PATCH/PUT /interfaces/1
  def update
    bulk_ints = params
    device = Device.find(bulk_ints['device_id'])
    
    bulk_ints['ints'].keys.each do |int_name|
      if bulk_ints['ints'][int_name]['used'] == 'yes'
        (bandwidth,description) = get_interface_metadata_by_name(device.hostname,int_name)
        interface = device.interfaces.find_by(:name => int_name)
        if interface
          #update to use the current bandwidth and linktype
          interface.update(:description => description,
                           :bandwidth => bandwidth,
                           :link_type_id => bulk_ints['ints'][int_name]['link_type_id'])
        else
          #create a new interface
          logger.debug "The object is #{int_name},#{description},#{bandwidth},#{bulk_ints['ints'][int_name]['link_type_id']}"
          device.interfaces.create(:name => int_name,
                                 :description => description,
                                 :bandwidth => bandwidth,
                                 :link_type_id => bulk_ints['ints'][int_name]['link_type_id'])
        end
      else
        #the interface has been de-selected or was not selected, destory the entry if needed
        interface = device.interfaces.find_by(:name => int_name)
        interface.destroy if interface
      end
    end
    redirect_to devices_url
  end

end
