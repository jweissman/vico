module Vico
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
      message = "You are flying over the world. You see cities among vast forests. Landmark buildings peek above the canopy. You see #{@clients.count} others (#{@clients.values.map(&:name).join('; ')})"
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
end
