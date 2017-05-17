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
  class WorldMap
    attr_reader :width, :height, :field
    def initialize(width:, height:)
      @width = width
      @height = height
      @field = self.class.generate_field(width, height)
    end

    def area
      @width * @height
    end

    def self.generate_field(w,h)
      field = Array.new(h) do
        Array.new(w) do
          rand > 0.02 ? 1 : 0
        end
      end
      2.times { field = smooth_field(field) }
      field
    end

    def self.smooth_field(field)
      field.map.each_with_index do |row, y|
        row.map.each_with_index do |cell, x|
          # average value with surrounding cells?
          average_neighbor_value(field, x, y)
        end
      end
    end

    def self.average_neighbor_value(field, cell_x, cell_y)
      total = 0
      count = 0
      (cell_x-1..cell_x+1).each do |x|
        (cell_y-1..cell_y+1).each do |y|
          if field[y] && field[y][x]
            total += field[y][x]
            count += 1
          end
        end
      end
      (total / count).to_i
    end
  end

  class World
    attr_reader :name, :map
    def initialize(name:)
      @name = name
      @map = WorldMap.new(width: 60, height: 30)
      # @cities = []
    end
  end

  class Zone
    attr_reader :address
    def initialize(address:)
      @address = address
    end
  end

  class Pawn
    attr_reader :name, :x, :y
    def initialize(name:, x:, y:)
      @name = name
      @x = x
      @y = y
    end

    def move!(direction)
      case direction
      when 'north' then @y -= 1
      when 'south' then @y += 1
      when 'east'  then @x -= 1
      when 'west'  then @x += 1
      else puts "UNKNOWN DIRECTION #{direction}"
      end
    end
  end

  class Server < TCPServer
    def halt!
      log.info "HALT SERVER!"
      # $stdout.puts "===> HALT SERVER <==="
      @halted = true
      close
    end

    def log
      @logger ||= Logger.new("log/world.log")
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
            handle(client)
          rescue
            log.error $!
          ensure
            dropped(client)
            client.close
          end
        end
      end
      puts "===> LISTEN DONE"
    end

    def dropped(client)
      # override in subclass
    end
  end

  class Controller
    def initialize(world:)
      @world = world
      @clients = {}
    end

    def iam(client, name)
      @clients[client] = Pawn.new(name: name, x: 10, y: 10)
      return current_environment(client).merge(description: "Welcome to #{@world.name}, #{name}!")
    end

    def drop(the_client) #name)
      @clients.reject! { |client| client == the_client }
      # do |cl, user|
      #   user.name == name
      # end
    end

    def look(client)
      # hmmm, if we enter a zone we need to handoff (proxy)...
      # pawn = @clients[client]
      message = "You see cities among vast forests. Landmark buildings peek above the canopy. You see #{@clients.count} others (#{@clients.values.map(&:name).join('; ')})"
      return current_environment(client).merge(description: message)
    end

    def go(client, direction)
      pawn = @clients[client]
      $stdout.puts "MOVE CLIENT #{pawn.name} IN DIRECTION #{direction}"
      pawn.move!(direction)
      return current_environment(client).merge(description: "You move #{direction}")
    end

    # protected
    def current_environment(the_client)
      {
        pawns: @clients.map do |client, pawn|
          { name: pawn.name, you: (client == the_client), x: pawn.x, y: pawn.y }
        end,
        map: @world.map.field,
        legend: [ :water, :land, :city ],
        world: { name: @world.name }
      }
    end
  end

  class WorldServer < Server
    attr_reader :world, :port
    def initialize(world:, port: 7060)
      log.info "---> World server would start..."
      @world = world
      @port = port
      @controller = Controller.new(world: @world)
      super(@port) rescue $stdout.puts $!
      log.info "---> WORLD SERVER STARTED"
    end

    def client_done?(client)
      log.info "---> Halted? #{halted?} / Client closed? #{!Comms.test!(socket: client)}"
      halted? || !(Comms.test!(socket: client)) # || client.closed?
    end

    def broadcast!
      @clients.each do |client|
        log.info "BROADCAST TO CLIENT #{client}"
        client_env = @controller.current_environment(client)
        Comms.send(client_env, socket: client)
      end
    end

    def process_message(client)
      log.info "==== ATTEMPT PROCESS MESSSAGE FROM CLIENT"
      if (message = Comms.read(socket: client))
        begin
          log.info "===> GOT MESSAGE #{message}"
          command_elements = message[:command].split(' ')
          command, *args = *command_elements
          response = @controller.public_send(command, client, *args)
          log.info "===> BUILD RSP #{response}"
          Comms.send(response, socket: client)
          broadcast!
        rescue => ex
          log.info "Encountered exception processing #{message}: " + ex.message
          log.info ex.backtrace
          Comms.send({description: "unable to handle command #{message}"}, socket: client)
          # client.puts( { error: "unknown command #{command}", description: "no such command available #{command}" }.to_bson )
        end
      end
      # sleep 0.1
    end

    def handle(client)
      log.info "===> HANDLE CLIENT STARTED"
      until client_done?(client)
        process_message(client)
      end
      log.info "===> HANDLE CLIENT HALTED"
    end

    def dropped(client)
      log.info("CLIENT DROPPED!!!!!")
      @controller.drop(client)
      @clients.delete(client)
      broadcast!
    end
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
