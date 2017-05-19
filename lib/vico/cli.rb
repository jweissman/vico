require 'thor'
require 'vico'

module Vico
  module Name
    def self.generate!
      adjs = %w[ wooly wild weird wonderful wannabe weeping whataboutist waxy wheeling warlike ]
      nouns = %w[ wallaby walrus warthog whale wasp narwhal wildebeest wondertron willow winterbear ]
      [ adjs.sample, nouns.sample ].join('_')
    end
  end

  class CLI < Thor
    desc "hello NAME", "say hello to NAME"
    def hello(name)
      puts "Hello #{name}"
    end

    desc "world NAME", "start world NAME"
    def world(name='omnia')
      puts "SERVE WORLD #{name}"

      # TODO same check for city...
      if World.where(name: name).any?
        world = World.where(name: name).first
      else
        world = World.new(name: name)
        world.save
        map = SpaceMap.new(width: 50, height: 20) #, space: world)
        map.generate!
        map.save
        world.space_map = map
        map.save
      end

      # binding.pry

      server = Server.new(space: world)
      server.listen!
    end

    desc "city NAME", "start city NAME"
    def city(name='aeternitas')
      puts "SERVE CITY #{name}"
      if City.where(name: name).any?
        city = City.where(name: name).first
      else
        city = City.new(name: name)
        city.save
        map = SpaceMap.new(width: 120, height: 80)
        map.generate!
        map.save
        city.space_map = map
        map.save
      end
      server = Server.new(space: city, register: true, port: 7070)
      server.listen!
    end

    # desc "zone ADDRESS", "start zone with ADDRESS"
    # def zone(address)
    #   puts "SERVE ZONE #{address}"
    #   ZoneServer.new(address: adress)
    # end

    # plaintext, line-oriented
    # console/cli/os
    # core of uniscript
    desc "text", "connect to world over text interface"
    def text
      puts "---> Launch text interface to world!"
      text_client = Text.new
      # text_client.connect!
      text_client.engage!
    end

    desc "screen", "connect to world over screen interface"
    def screen
      puts "---> Launch screen interface to world!"
      screen_client = Screen::Engine.new
      # screen_client.connect!
      screen_client.engage!
    end
  end
end
