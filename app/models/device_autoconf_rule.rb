class DeviceAutoconfRule < ActiveRecord::Base

    #need to add hostname_regex format validation at some point
    validates_presence_of :hostname_regex
    validates_presence_of :network
    #only allow IPv4 /22-32 networks
    validates_format_of :network, :with => /\A(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\/(22|23|24|25|26|27|28|29|30|31|32)\z/


end
