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
    def world(name=Name.generate!)
      puts "SERVE WORLD #{name}"
      world = World.new(name: name)
      server = WorldServer.new(world: world)
      server.listen!
    end

    desc "zone ADDRESS", "start zone with ADDRESS"
    def zone(address)
      puts "SERVE ZONE #{address}"
      ZoneServer.new(address: adress)
    end

    # plaintext, line-oriented
    # console/cli/os
    # core of uniscript
    desc "text", "connect to world over text interface"
    def text
      puts "---> Launch text interface to world!"
      text_client = Text.new
      text_client.connect!
      text_client.engage!
    end

    desc "screen", "connect to world over screen interface"
    def screen
      puts "---> Launch screen interface to world!"
      screen_client = Screen::VisualClient.new
      screen_client.connect!
      screen_client.engage!
    end
  end
end
