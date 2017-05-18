require 'pry'
require 'socket'
require 'json'
# require 'bson'
require 'readline'
require 'curses'

require 'vico/version'
require 'vico/comms'

## client deps

require 'vico/client'
require 'vico/text'
require 'vico/screen'


## server deps

require 'vico/world_map'
require 'vico/server_helpers'
require 'vico/controller'

module Vico
  class World
    attr_reader :name, :map
    def initialize(name:)
      @name = name
      @map = WorldMap.new(width: 40, height: 10)
      # @cities = []
    end
  end

  class City
    attr_reader :name, :map
    def initialize(name:)
      @name = name
      @map = WorldMap.new(width: 15, height: 15)
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
      @clients.each do |client|
        log.info "BROADCAST TO CLIENT #{client}"
        client_env = @controller.current_environment(client)
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

  # class CityServer < TCPServer
  #   include ServerHelpers
  #   attr_reader :city

  #   def initialize(city:, port: 7061)
  #     @city = city
  #     @port = port
  #     super(@port) rescue $stdout.puts $!
  #     log.info "CITY SERVER STARTED"
  #     launch!
  #   end
  # end

  # class ZoneServer
  #   attr_reader :address
  #   def initialize(address:)
  #     puts "---> Zone server would start..."
  #     @address = address
  #   end
  # end
end
