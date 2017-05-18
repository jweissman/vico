module Vico
  class Controller
    def initialize(space:)
      @space = space
      @clients = {}
      @subspaces = []
    end

    ## pawn management...
    #
    def iam(client, name)
      @clients[client] = Pawn.new(name: name, x: 10, y: 10)
      return current_environment(client).merge(description: "Welcome to #{@space.name}, #{name}!")
    end

    def drop(the_client) #name)
      @clients.reject! { |client, pawn| client == the_client }
      @subspaces.reject! { |subspace| subspace[:connection] == the_client }
      true
      # do |cl, user|
      #   user.name == name
      # end
    end

    def look(client)
      # hmmm, if we enter a zone we need to handoff (proxy)...
      message = "You are flying over the space." # You see cities among vast forests. Landmark buildings peek above the canopy.

      if @subspaces.any?
        message += "You see cities among vast forests: #{@subspaces.map { |sp| sp[:name] }.join(', ')}."
      end

      if (other_clients = (@clients.keys - [client])).any?
        other_people = other_clients.map { |cl| @clients[cl] }
        message += "You see #{other_people.count} other people: (#{other_people.map(&:name).join('; ')})"
      end

      return current_environment(client).merge(description: message)
    end

    def go(client, direction)
      pawn = @clients[client]
      if %w[ north south east west ].include?(direction)
        $stdout.puts "MOVE CLIENT #{pawn.name} IN DIRECTION #{direction}"
        pawn.move!(direction)
        return current_environment(client).merge(description: "You move #{direction}")
      else
        $stdout.puts "CLIENT WANTS TO GO #{direction}"
        if direction == 'down'
          location = [ pawn.x, pawn.y ]
          # any subspace matches?
          if (matching_subspace = @subspaces.detect { |it| it[:location] == location })
            return { description: "You enter #{matching_subspace[:name].capitalize}!", host: matching_subspace[:host], port: matching_subspace[:port] }

            # matching_subspace.active_clients << client
            # binding.pry
            # move client to this subspace!!!!!
            # need to route this clients messages TO the space now... (this could get gnarly...!)
            # but we need the paper trail (how they GOT here) to be able to get back out (if ambig...)
          end
          # land wherever the client is, if flying...
        elsif (matching_landmark = @subspaces.detect { |it| it[:name] == direction })
          location = matching_landmark[:location]
          pawn.set_pos(*location)
          return { description: "You move to #{matching_landmark[:name]} at #{location}" }
        else
          raise "Unknown direction to move: '#{direction}'! (Should be north/south/east/west/up/down)"
        end
      end
    end

    ## handle registration of subspaces (cities...)
    def register(client, subspace_kind, subspace_name, host, port, x, y) #x = 2, y = 1)
      $stdout.puts "===> REGISTER #{subspace_kind} (name=#{subspace_name})"
      @subspaces << {
        id: @subspaces.count + 2,
        name: subspace_name,
        kind: subspace_kind,
        location: [x.to_i,y.to_i],
        host: host,
        port: port,
        connection: client,
        active_clients: []
      }
      true
    end

    # protected
    def current_environment(the_client)
      {
        pawns: @clients.map do |client, pawn|
          { name: pawn.name, you: (client == the_client), x: pawn.x, y: pawn.y }
        end,
        map: @space.map.field_with_landmarks(landmarks: @subspaces),
        legend: @space.map.legend(landmarks: @subspaces), # [ :water, :land, :city ],
        space: { name: @space.name }
      }
    end
  end
end
