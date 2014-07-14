require 'fog'
require 'rest-client'

DIR = '/home/yarddog/workspace'
PORT = 60086

# extending this class for yarddog
class Fog::Compute::AWS::Server

    def url req
        "#{private_ip_address}:#{PORT}/#{req}"
    end

    def connected?
        ready? && private_ip_address &&
            (RestClient.get (url 'test') rescue false)
    end

    def upload_image file
        fail 'Not connected.' unless connected?
        # high timeout for debugging purposes
        res = RestClient::Resource.new("#{private_ip_address}:#{PORT}/", timeout: 999999)
        res['images'].post file: File.new(file)
    end

end
