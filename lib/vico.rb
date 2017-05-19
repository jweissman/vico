# stdlibs
require 'socket'
require 'json'

# gems
require 'pry'
require 'readline'
require 'curses'
require 'sequel'

# general deps

require 'vico/version'
require 'vico/comms'

## client deps

require 'vico/client'
require 'vico/text'
require 'vico/screen'


## server deps

require 'vico/server_helpers'
require 'vico/controller'
require 'vico/server'
# require 'vico/space_map'


## models (server-only)
require 'vico/models'

module Vico
  class World < Space
  end

  class City < Space
  end

  class Zone < Space
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
