require 'fog'
require 'base64'
require_relative '../../lib/yarddog-conf'

IMAGE = 'ami-018c9568' # Ubuntu 14.04 64-bit
SUBNET = 'subnet-5e4f4236' # 10.42.3.x/24, us-east-1a
SECURITY_GROUP_IDS = ['sg-7440961b', 'sg-b3a4c4d6']
BREEDS = ["beagle", "laborador", "terrier", "bulldog", "chihuahua", "shepherd", "hound", "spaniel", "retriever", "schnauzer", "shiba", "pinscher", "mastiff", "collie"]

class EC2Instance

    # requires valid instance of Fog::Compute
    def initialize compute
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
    attr_reader :compute

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
    end

    # of the form 'i-{hex string}'
    def connect_to id
        @server = @compute.servers.get id
    end
    
end
