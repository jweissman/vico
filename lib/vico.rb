require 'pry'
require 'socket'
require 'json'
# require 'bson'
require 'readline'
require 'curses'

require 'vico/version'
require 'vico/comms'
require 'vico/client'
require 'vico/screen'

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
      @clients = {}
    end

    def iam(client, name)
      @clients[client] = Pawn.new(name: name)

      {
        hello: name,
        description: "Welcome to #{@world.name}, #{name}!"
      }
    end

    def drop(client) #name)
      @clients.reject! { |cl, user| user.name == name }
    end

    def look(client)
      # hmmm, if we enter a zone we need to handoff (proxy)...
      {
        description: "You are flying over #{@world.name}. You see cities among vast forests. Landmark buildings peek above the canopy. You see #{@clients.count} people: #{@clients.values.map(&:name).join('; ')}",
        map: # Array.new(32) { Array.new(32) { Integer(rand * 3) } },
        [
          [ 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0 ],
          [ 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0 ],
          [ 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0 ],
          [ 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0 ],
          [ 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0 ],
          [ 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0 ],
          [ 0, 0, 0, 0, 1, 1, 0, 0, 1, 2, 1, 1, 0 ],
          [ 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0 ],
          [ 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0 ],
        ],
        legend: [ :water, :land, :city ],
        pawn: { x: 1, y: 1 }
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
        if (message = Comms.read(socket: client)) #data = client.gets.chomp)
          begin
            # message = Comms.decode(data) #parse_message(data)
            $stdout.puts "===> GOT MESSAGE #{message}"
            command_elements = message[:command].split(' ')
            command, *args = *command_elements
            response = @controller.public_send(command, client, *args)
            Comms.send(response, socket: client)
            # client.puts(Comms.encode(response)) #.to_bson
          rescue => ex
            $stdout.puts "Encountered exception processing #{message}: " + ex.message
            client.puts( { error: "unknown command #{command}", description: "no such command available #{command}" }.to_bson )
          end
        end
      end
      puts "===> HANDLE CLIENT HALTED"
    end

    # def parse_message(data)
    #   message = JSON.parse(data)
    #   # bytes = BSON::ByteBuffer.new(data)
    #   # message = Hash.from_bson(bytes)
    #   $stdout.puts "---> server parsed: #{message}"
    #   return message
    # end
  end

  class ZoneServer
    attr_reader :address
    def initialize(address:)
      puts "---> Zone server would start..."
      @address = address
    end
  end

  # first client!!
  class Text < Client
    def initialize
      puts "---> Text would connect to local world server..."
      super
    end

    def prompt; "vico> " end

    def engage!
      th = poll do |event|
        $stdout.puts event[:description]
      end

      begin
        while !quit?
          sleep 0.05
          puts
          msg = Readline.readline(prompt, true)
          if msg
            cmd = msg.chomp
            if cmd == 'quit' or cmd == 'exit'
              quit!
            else
              command(cmd) #msg.chomp)
            end
          end
        end
      rescue => ex
        $stdout.puts ex.message
        $stdout.puts ex.backtrace
      end

      th.join
    # ensure
    #   @socket.close
    end
  end
end
