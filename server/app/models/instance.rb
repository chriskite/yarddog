require 'fog'
require 'rest-client'

DIR = '/home/yarddog/workspace'
AGENT_PORT  = 60086
DOCKER_PORT = 60186

# extending this class for yarddog
class Fog::Compute::AWS::Server

  def connected?
    agent['test'].get rescue false
  end

  def upload_image file
    agent['images'].post file: File.new(file)
  end

  def kill container, image
    docker["containers/#{container}"].delete
    docker["images/#{image}"].delete
  end

  private
  # abstractions for connection, which fail automatically

  def agent
    return @agent if @agent
    if ready? && private_ip_address
      @agent = RestClient::Resource.new(
        "#{private_ip_address}:#{AGENT_PORT}/",
        timeout: 999999
      )
    else
      fail 'Server is not ready.'
    end
  end

  def docker
    return @docker if @docker
    if ready? && private_ip_address
      @docker = RestClient::Resource.new(
        "#{private_ip_address}:#{DOCKER_PORT}/",
        timeout: 999999
      )
    else
      fail 'Server is not ready.'
    end
  end

end
