module InterfacesHelper
  
  def get_interface_metadata(id)
    client = MongoClient.new(Setting.first.mongodb_db_hostname, Setting.first.mongodb_db_port)
    db     = client[Setting.first.mongodb_db_name]
    interface = Interface.find(id)
    hostname = interface.device.hostname
    collection = "targets"
    mtu = bandwidth = description = 0
    db[collection].find({'name' => hostname}).each do |meta_for_host|
      meta_for_host['interfaces'].each do |meta_for_int|
        if meta_for_int['name'] == interface.name
          description = meta_for_int['metadata']['description']
          bandwidth = meta_for_int['metadata']['ifSpeed']
          bandwidth = meta_for_int['metadata']['ifHighSpeed'] * 1000000  if bandwidth = 4294967295 #bandwidth is too high for ifSpeed, need to use ifHighSpeed
          mtu =  meta_for_int['metadata']['mtu']
        end
      end
    end
    return bandwidth, description
  end

  def get_poller_health_of_interface(id)
    client = MongoClient.new(Setting.first.mongodb_db_hostname, Setting.first.mongodb_db_port)
    db     = client[Setting.first.mongodb_db_name]
    recordsShortNames = ['i','o']
    interface = Interface.find(id)
    device = interface.device
    hostname = device.hostname
    collection = "host.#{hostname}"
    int_measure_count = 0

    db[collection].find({'_id' => {:$gt => (Time.now.to_i - Setting.first.mongodb_test_window), :$lt => Time.now.to_i}}).each do |measurement|
      int_measure_count += 1 if measurement['rate'][interface.name][recordShortNames[0]]
    end
    if int_measure_count > 0
      return true
    else
      return false
    end
  end

end
