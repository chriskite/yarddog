require 'rubygems'
require 'bundler/setup'
require 'jimson'
require 'docker'

module YardDog
  class Agent

    def initialize(server_ip, agent_id)
      @server = Jimson::Client.new(server_ip)
      @agent_id = agent_id
    end

    def run
      loop do
        resp = @server.request_task(agent_id)
        
        # if told to shut down, exit
        break if "shutdown" == resp

        image = resp["image"]
        task_id = resp["task_id"]

        docker_pull(image)

        container_id = docker_run(image)

        exit_code = docker_wait(container_id)

        @server.task_done(@agent_id, task_id, exit_code)
      end
    end

    def docker_pull(image)

    end

    def docker_run(image)

    end

    def docker_wait(container_id)

    end

  end
end
