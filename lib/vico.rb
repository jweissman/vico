require 'vico/version'
require 'pry'
require 'socket'
require 'bson'
require 'curses'

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

  class Server < TCPServer
    def halt!
      $stdout.puts "===> HALT SERVER <==="
      @halted = true
      close
    end

    def halted?
      @halted ||= false
    end

    def listen!
      until halted? do
        Thread.fork(accept) do |client|
          begin
            $stdout.puts("Accept client: #{client.peeraddr}")
            # parse client command, handoff to responder...
            # client.puts "Hello...!"
            handle(client)
          ensure
            client.close
          end
        end
      end
      puts "===> LISTEN DONE"
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
      super(@port) rescue $stdout.puts $!
      $stdout.puts "---> WORLD SERVER STARTED"
    end

    def handle(client)
      until halted? do
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
      puts "===> HANDLE CLIENT HALTED"
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
    end
    def connect!
      puts "---> Client would connect to host #{host}..."
      @socket = TCPSocket.open(@host, @port)
    end

    protected

    def command(msg)
      data = { command: msg }.to_bson
      @socket.puts(data)
    end

    def poll
      Thread.new do
        loop do
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

  # first client!!
  class Text < Client
    def initialize
      puts "---> Text would connect to local world server..."
      super
    end

    def engage!
      th = poll do |event|
        $stdout.puts event[:description]
      end

      begin
        loop do
          sleep 0.25
          puts
          print ' vico> '
          msg = $stdin.gets
          command(msg.chomp) if msg
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

  class Screen < Client
    def initialize
      puts "---> Screen would connect to local world server..."
      super
      # engage!
    end

    def engage!
      th = poll do |event|
        $stdout.puts event
      end

      th.join
    end
  end
end
