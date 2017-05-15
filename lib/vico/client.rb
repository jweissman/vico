module Vico
  class Client
    attr_reader :host

    def initialize(host: 'localhost', port: 7060)
      @host = host
      @port = port
    end

    def connect!
      puts "---> Client would connect to host #{host}..."
      @socket = TCPSocket.open(@host, @port)
    end

    def quit!
      @comms_thread.kill
      @quit = true
    end

    def quit?
      @quit ||= false
    end

    protected

    def command(msg)
      data = { command: msg }.to_bson
      @socket.puts(data)
    end

    def poll
      @comms_thread = Thread.new do
        until quit? do
          begin
            if (data = @socket.gets)
              # puts "===> CLIENT READ DATA #{data}"
              bytes = BSON::ByteBuffer.new(data.chomp)
              parsed = Hash.from_bson(bytes)
              yield(parsed)
            end
          rescue
            $stdout.puts $!
          end
        end
      end
    end
  end
end
