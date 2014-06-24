require 'fog'
require 'base64'
require_relative '../../lib/yarddog-conf'

IMAGE = 'ami-d4bd46bc' # yarddog-base
SUBNET = 'subnet-5e4f4236' # 10.42.3.x/24, us-east-1a
SECURITY_GROUP_IDS = ['sg-7440961b', 'sg-b3a4c4d6']
BREEDS = %w(beagle laborador terrier bulldog chihuahua shepherd hound spaniel retriever schnauzer shiba pinscher mastiff collie)
PORT = 60086

class EC2Instance
    attr_reader :compute, :server

    # requires valid instance of Fog::Compute
    def initialize compute=nil
        @conf = YarddogConf.new.parse_home_file['Server']
        if compute
            @compute = compute
        else
            @compute = Fog::Compute.new({
                provider: 'AWS',
                aws_access_key_id: @conf['aws_key'],
                aws_secret_access_key: @conf['aws_secret_key'],
            })
        end
    end

    def spin_up type="t1.micro"
        @server = @compute.servers.create({
            flavor_id: type,
            security_group_ids: SECURITY_GROUP_IDS,
            image_id: IMAGE,
            subnet_id: SUBNET,
            key_name: 'yarddog',
        })
        @compute.tags.create({
            resource_id: @server.identity,
            key: "Name",
            value: "#{BREEDS[rand(BREEDS.size)]} [yarddog]",
        })
        @server.wait_for { ready? }
        @addr = @server.private_ip_address
    end

    # of the form 'i-{hex string}'
    def connect_to id
        @server = @compute.servers.get id
        @addr = @server.private_ip_address
    end

    def connected?
        return false if @server.nil? || !@server.ready?
        RestClient.get "#{@addr}:#{PORT}/test" rescue return false
        true
    end

end
