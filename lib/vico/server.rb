module Vico
  class Server < TCPServer
    include ServerHelpers

    attr_reader :space, :port
    def initialize(space:, port: 7060, register: false)
      log.info "---> Space server would start..."
      @space = space
      @port = port
      @controller = Controller.new(space: @space)
      super(@port) rescue $stdout.puts $!
      log.info "---> SPACE SERVER STARTED"

      launch_client! if register
    end

    def launch_client!
      @client = Client.new # need to act as client to city...
      @client.connect!
      log.info "CONNECTED TO SUPERSPACE!"

      @client.poll do |event|
        $stdout.puts "===> SUBSPACE SERVER GOT EVENT FROM SUPERSPACE: #{event}"
      end

      subspace_kind = space.class.name.downcase

      @client.command("register #{subspace_kind} #{@space.name} localhost #{@port} 2 2")
    end

    def broadcast!
      log.info "BROADCAST UPDATE"
      @clients.each do |client|
        # log.info "BROADCAST TO CLIENT #{client}"
        client_env = @controller.current_environment(client)
        log.info "BROADCAST: #{client_env}"
        Comms.send(client_env, socket: client)
      end
    end

    def process_message(client)
      # log.info "==== ATTEMPT PROCESS MESSSAGE FROM CLIENT"
      if (message = Comms.read(socket: client))
        begin
          log.info "===> GOT MESSAGE #{message}"
          command_elements = message[:command].split(' ')
          command, *args = *command_elements
          response = @controller.public_send(command, client, *args)
          if response
            log.info "===> BUILD RSP #{response}"
            Comms.send(response, socket: client)
          end

          # update current state...
          broadcast!
        rescue => ex
          log.info "Encountered exception processing #{message}: " + ex.message
          log.info ex.backtrace
          Comms.send({description: "unable to handle command #{message}"}, socket: client)
        end
      end
    end

    def dropped(client)
      log.info("CLIENT DROPPED!!!!!")
      @controller.drop(client)
      @clients.delete(client)
      broadcast!
    end
  end
end
