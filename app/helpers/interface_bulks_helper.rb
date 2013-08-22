module InterfaceBulksHelper

  def get_interfaces_for_device(id)
    client = MongoClient.new(Setting.first.mongodb_db_hostname, Setting.first.mongodb_db_port)
    db     = client[Setting.first.mongodb_db_name]
    device = Device.find(id)
    hostname = device.hostname
    collection = "targets"
    interfaces = []
    db[collection].find({'name' => hostname}).each do |meta_for_host|
      meta_for_host['interfaces'].each do |meta_for_int|
        interfaces << meta_for_int['name']
      end
    end
    return interfaces
  end

  def get_interface_metadata_by_name(hostname,int_name)
    client = MongoClient.new(Setting.first.mongodb_db_hostname, Setting.first.mongodb_db_port)
    db     = client[Setting.first.mongodb_db_name]
    collection = "targets"
    mtu = bandwidth = description = 0
    db[collection].find({'name' => hostname}).each do |meta_for_host|
      meta_for_host['interfaces'].each do |meta_for_int|
        if meta_for_int['name'] == int_name
          description = meta_for_int['metadata']['description']
          bandwidth = meta_for_int['metadata']['ifSpeed']
          bandwidth = meta_for_int['metadata']['ifHighSpeed'] * 1000000  if bandwidth = 4294967295 #bandwidth is too high for ifSpeed, need to use ifHighSpeed
          mtu =  meta_for_int['metadata']['mtu']
        end
      end
    end
    return bandwidth, description
  end
end
