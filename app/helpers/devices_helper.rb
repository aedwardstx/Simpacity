module DevicesHelper

  def get_list_of_interfaces(id)
    client = MongoClient.new(Setting.first.mongodb_db_hostname, Setting.first.mongodb_db_port)
    db     = client[Setting.first.mongodb_db_name]
    device = Device.find(id)
    hostname = device.hostname
    collection = "host.#{hostname}"
    int_names = []

    db[collection].find({'_id' => {:$gt => (Time.now.to_i - Setting.first.mongodb_test_window), :$lt => Time.now.to_i}}).each do |measurement|
      measurement['rate'].keys.each do |int|
        int_names << int if not int_names.include? int
      end
    end    
    return int_names
  end

  def get_poller_health_for_device(id)
    client = MongoClient.new(Setting.first.mongodb_db_hostname, Setting.first.mongodb_db_port)
    db     = client[Setting.first.mongodb_db_name]

    device = Device.find(id)
    hostname = device.hostname
    collection = "host.#{hostname}"
    #return db.inspect
    if db[collection].find({'_id' => {:$gt => (Time.now.to_i - Setting.first.mongodb_test_window), :$lt => Time.now.to_i}}).count > 0
    #return @db[collection].find({'_id' => {:$gt => (Time.now.to_i - Setting.first.mongodb_test_window), :$lt => Time.now.to_i}}).inspect
      return true
    else 
      return false
    end
  end
end
