require 'fog'
require 'base64'
require_relative '../../lib/yarddog_conf'

class EC2
    IMAGE = 'ami-0ca56064' # yarddog-base
    SUBNET = 'subnet-5e4f4236' # 10.42.3.0/24, us-east-1a
    YARDDOG_GROUP = 'sg-b3a4c4d6' # vpc-yarddog-test
    SSH_GROUP = 'sg-7440961b' # vpc-ssh
    SECURITY_GROUP_IDS = ['sg-b3a4c4d6', 'sg-7440961b']
    BREEDS = %w(beagle laborador terrier bulldog chihuahua shepherd hound spaniel retriever schnauzer shiba pinscher mastiff collie)
    PORT = 60086

    attr_reader :compute

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
        # The require has to be here because Fog does something
        # weird with the Fog::Compute::AWS::Server class.
        # It doesn't exist before we call Fog::Compute#new.
        require_relative './instance.rb'
        find
    end

    def spin_up type="t1.micro"
        server = @compute.servers.create({
            flavor_id: type,
            security_group_ids: SECURITY_GROUP_IDS,
            image_id: IMAGE,
            subnet_id: SUBNET,
            key_name: 'yarddog',
            user_data: generate_script,
        })
        @compute.tags.create({
            resource_id: server.identity,
            key: "Name",
            value: "#{BREEDS[rand(BREEDS.size)]} [yarddog]",
        })
        server.wait_for { ready? }
        @yd_servers << server
        return server
    end

    def find
        @yd_servers = @compute.servers.all(
            'instance.group-id' => YARDDOG_GROUP
        )
    end

    # of the form 'i-{hex string}'
    def connect_to id
        server = @compute.servers.get id
        if server.groups.include? YARDDOG_GROUP
            @yd_servers << server
        end
        return server
    end

    def check_all
        @yd_servers.select do |server|
            server.connected?
        end
    end

    private
    def generate_script
        # TODO
    end
end
