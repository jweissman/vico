module Vico
  class Client
    attr_reader :host, :port, :comms_thread

    def initialize(host: 'localhost', port: 7060)
      @host = host
      @port = port
    end

    def connect!
      puts "---> Client would connect to host #{host}..."
      begin
        @socket = TCPSocket.open(@host, @port)
      rescue
        puts "=== COULD NOT ESTABLISH CONNECTION! ==="
        puts $!
        exit(-1)
      end
    end

    def quit!
      @socket.close
      @comms_thread.kill
      @quit = true
    end

    def quit?
      @quit ||= false
    end

    def command(msg)
      raise "Socket not connected!" unless @socket
      data = JSON.dump command: msg # } #.to_bson
      @socket.puts(data)
    end

    def poll
      @comms_thread = Thread.new do
        raise "Socket not connected!" unless @socket
        until quit? do
          begin
            if (message = Comms.read(socket: @socket)) #data = @socket.gets)
              # $stdout.puts "===> CLIENT READ DATA #{data}"
              # bytes = BSON::ByteBuffer.new(data.chomp)
              # parsed = Hash.from_bson(bytes)
              # parsed = Comms.decode(data) # JSON.parse(data)
              yield(message)
            end
          rescue
            $stdout.puts $!
          end
        end
      end
    end
  end
end
