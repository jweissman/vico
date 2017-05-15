require 'vico/version'
require 'pry'
require 'socket'
require 'bson'

module Vico
  class World
    attr_reader :name
    def initialize(name:)
      @name = name
    end
  end

  class Zone
    attr_reader :address
    def initialize(address:)
      @address = address
    end
  end

  class Pawn
    attr_reader :name
    def initialize(name:)
      @name = name
    end
  end

  # class Protocol
  #   def self.encode(message)
  #   end

  #   def self.decode(bytes)
  #   end
  # end

  class Server < TCPServer
    def listen!
      loop do
        Thread.fork(accept) do |client|
          begin
            # parse client command, handoff to responder...
            # client.puts "Hello...!"
            handle(client)
          ensure
            client.close
          end
        end
      end
    end
  end

  class Controller
    def initialize(world:)
      @world = world
      # @user = Pawn.new(name: "Someone")
    end

    def look
      # hmmm, if we enter a zone we need to handoff (proxy)...
      {
        description: "You are flying over #{@world.name}. You see cities among vast forests. Landmark buildings peek above the canopy.",
        map: [
          [ 0, 0, 0, 1, 0, 0, 0 ],
          [ 0, 1, 1, 1, 1, 0, 0 ],
          [ 0, 0, 1, 2, 1, 1, 0 ],
          [ 1, 0, 1, 1, 1, 0, 0 ],
        ],
        legend: [ :water, :land, :city ]
      }
    end
  end

  class WorldServer < Server
    attr_reader :world, :port
    def initialize(world:, port: 7060)
      $stdout.puts "---> World server would start..."
      @world = world
      @port = port
      @controller = Controller.new(world: @world)
      super(@port)
      $stdout.puts "---> WORLD SERVER STARTED"
    end

    def handle(client)
      loop do
        if (data = client.gets.chomp)
          begin
            message = parse_message(data)
            command = message[:command]
            response = @controller.public_send(command)
            client.puts response.to_bson
          rescue => ex
            $stdout.puts "Encountered exception processing #{message}: " + ex.message
            client.puts( { error: "unknown command #{command}", description: "no such command available #{command}" }.to_bson )
          end
        end
      end
    end

    def parse_message(data)
      bytes = BSON::ByteBuffer.new(data)
      message = Hash.from_bson(bytes)
      $stdout.puts "---> server parsed: #{message}"
      return message
    end
  end

  class ZoneServer
    attr_reader :address
    def initialize(address:)
      puts "---> Zone server would start..."
      @address = address
    end
  end

  class Client
    attr_reader :host

    def initialize(host: 'localhost', port: 7060)
      @host = host
      @port = port
      puts "---> Client would connect to host #{host}..."
      @socket = TCPSocket.open(@host, @port)
      engage!
    end

    def command(msg)
      puts "===> SEND COMMAND #{msg}"
      data = { command: msg }.to_bson
      @socket.puts(data)
      puts "===> SENT!"
    end

    protected
    def engage!
      th = Thread.new do
        loop do
          begin
            if (data = @socket.gets)
              puts "===> CLIENT READ DATA #{data}"
              bytes = BSON::ByteBuffer.new(data.chomp)
              parsed = Hash.from_bson(bytes)
              $stdout.puts "received : #{parsed[:description]}"
            end
          rescue
            $stdout.puts $!
          end
        end
      end

      begin
        loop do
          puts
          print ' > '
          msg = $stdin.gets.chomp
          command(msg)
        end
      rescue => ex
        $stdout.puts ex.message
        $stdout.puts ex.backtrace
      end

      th.join
    ensure
      @socket.close
    end
  end

  # first client!!
  class Text < Client
    def initialize
      puts "---> Text would connect to local world server..."
      super
    end
  end

  class Screen < Client
    def initialize
      puts "---> Screen would connect to local world server..."
    end
  end
end
