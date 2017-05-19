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

require 'vico/space_map'
require 'vico/server_helpers'
require 'vico/controller'
require 'vico/server'


## models (server-only)

module Vico
  class Space
    attr_reader :name, :map
    def initialize(name:, width: 10, height: 10)
      @name = name
      @map = SpaceMap.new(width: width, height: height)
    end
  end

  class World < Space
    # attr_reader :name, :map
    # def initialize(name:)
    #   @name = name
    #   @map = WorldMap.new(width: 40, height: 10)
    #   # @cities = []
    # end
  end

  class City < Space
    # attr_reader :name, :map
    # def initialize(name:)
    #   @name = name
    #   @map = WorldMap.new(width: 15, height: 15)
    # end
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

    def set_pos(x,y)
      @x, @y = x, y
    end
  end
end
