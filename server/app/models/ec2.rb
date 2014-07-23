require 'fog'
require 'base64'
require_relative '../../../lib/yarddog_conf'

class EC2
    IMAGE = 'ami-065c956e' # yarddog-base
    SUBNET = 'subnet-244f424c' # 10.42.4.0/24, us-east-1a, internet-connected
    YARDDOG_GROUP = 'sg-b3a4c4d6' # vpc-yarddog-test
    SSH_GROUP = 'sg-7440961b' # vpc-ssh
    SECURITY_GROUP_IDS = [YARDDOG_GROUP, SSH_GROUP]
    BREEDS = %w(beagle laborador terrier bulldog chihuahua
    shepherd hound spaniel retriever schnauzer shiba pinscher
    mastiff collie)
    PORT = 60086
    RATE_LIMIT = 60 #seconds

    attr_reader :compute

    # requires valid instance of Fog::Compute
    # initialization
    @conf = YarddogConf.new.parse_home_file['Server']
    @compute = Fog::Compute.new({
        provider: 'AWS',
        aws_access_key_id: @conf['aws_key'],
        aws_secret_access_key: @conf['aws_secret_key'],
    })
    # The require has to be here because Fog does something
    # weird with the Fog::Compute::AWS::Server class.
    # It doesn't exist before we call Fog::Compute#new.
    require_relative './instance.rb'
    Fog.credentials = Fog.credentials.merge({
        :private_key_path => File.expand_path(@conf['private_key_path']),
        :public_key_path => File.expand_path(@conf['public_key_path']),
    })
    @last = Time.new 0 # beginning of epoch
    @yd_servers = []

    def self.create type=nil
        type = "t1.micro" if type.nil?
        if Time.now - @last < RATE_LIMIT
          warn 'You are spinning servers up too fast. '        \
            'To avoid abuse from infinite loops, yarddog '     \
            'does not spin up servers faster than once every ' \
            "#{RATE_LIMIT} second#{RATE_LIMIT == 1 && '' || 's'}."
          return nil
        end
        @last = Time.now
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
            value: "#{generate_name} [yarddog]",
        })
        server.wait_for { connected? }
        @yd_servers << server
        return server
    rescue => e
        server.destroy if server
        raise e
    end

    def self.all
        # filter so that we won't interfere with the other servers
        @yd_servers = @compute.servers.all(
            'instance.group-id' => YARDDOG_GROUP
        )
    end

    # of the form 'i-{hex string}'
    def self.find id
        server = @compute.servers.get id
        return nil unless server
        if server.groups.include? YARDDOG_GROUP
            @yd_servers << server
        end
        return server
    end

    def self.generate_name
        used_names = @yd_servers.map{|s|s.tags["Name"].split.first}
        unused_names = BREEDS - used_names
        unused_names[rand(unused_names.size)]
    end

    # This is the script that will be started by root as soon as the machine
    # is ready. Within it is the yarddog-agent file that is in the project
    # directory, therefore it will be consistent with this version of the
    # project. It will be executed as the yarddog user in the background.
    #private
    def self.generate_script
        return <<SCRIPT
#!/bin/sh
cat \x3c\x3c'EC2_EOF' > /home/yarddog/yarddog-agent
#{File.read(File.expand_path('../../../../agent/bin/yarddog-agent', __FILE__))}
EC2_EOF
chown yarddog:users /home/yarddog/yarddog-agent
chmod +x /home/yarddog/yarddog-agent
sudo -u yarddog -i -b /home/yarddog/yarddog-agent
SCRIPT
    end

end
