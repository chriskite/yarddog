require 'fog'
require 'rest-client'

DIR = '/var/lib/yarddog_agent'
PORT = 60086

# extending this class for yarddog
class Fog::Compute::AWS::Server

    def url req
        "#{private_ip_address}:#{PORT}/#{req}"
    end

    def connected?
        ready? && private_ip_address && (RestClient.get (url 'test') rescue false)
    end

    def upload_image file
        # POST over HTTPS would proably be better but this works
        @server.scp(file, DIR)
        RestClient.post (url "images/new/#{file}")
    end

end
