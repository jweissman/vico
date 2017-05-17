module Vico
  # intended to be mixed into subclasses of TCPServer
  module ServerHelpers
    def halt!
      log.info "HALT SERVER!"
      # $stdout.puts "===> HALT SERVER <==="
      @halted = true
      close
    end

    def log
      @logger ||= Logger.new("log/server.log")
    end

    def halted?
      @halted ||= false
    end

    def listen!
      log.info "LISTEN"
      @clients = []
      until halted? do
        Thread.fork(accept) do |client|
          begin
            $stdout.puts("Accept client: #{client.peeraddr}")
            @clients << client
            # parse client command, handoff to responder...
            # client.puts "Hello...!"
            until client_done?(client)
              process_message(client)
            end
          rescue
            log.error $!
          ensure
            dropped(client)
            client.close
            @clients.delete(client)
          end
        end
      end
      puts "===> LISTEN DONE"
    end

    def dropped(client)
      # override in included class of TCPServer
    end

    def client_done?(client)
      log.info "---> Halted? #{halted?} / Client closed? #{!Comms.test!(socket: client)}"
      halted? || !(Comms.test!(socket: client)) # || client.closed?
    end

  end
end
