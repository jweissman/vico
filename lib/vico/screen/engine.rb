module Vico
  module Screen
    class Engine # < Vico::Client
      include Curses
      attr_accessor :map

      def initialize(host: 'localhost', port: 7060)
        @visited = [{host: host, port: port}]
        $client = Vico::Client.new(host: host, port: port)
      end

      def quit!
        log.info "QUITTTTT"
        $client.quit!
        [ @refresh_thread, @ui_thread ].map(&:kill)
        @quit = true
      end

      def quit?
        @quit ||= false
        # $client.quit? || (@quit ||= false)
        # @quit ||= ($client.quit? || false)
      end

      def listen(event)
        if event[:map] && event[:legend] # update map...
          # log.info  "---> GOT MAP #{event[:map]}"
          @map = Map.new(field: event[:map], legend: event[:legend])
        end

        if event[:pawns] # update pawn locations...
          log.info "UPDATE players: #{event[:pawns]}"
          @players = event[:pawns].map do |*attrs|
            Player.new(*attrs)
          end
        end

        if event[:space] # update world info
          log.info "UPDATE world / space -- name: #{event[:space][:name]}"
          @space = Space.new(name: event[:space][:name])
        end

        if event[:description]
          log.info "UPDATE description"
          @description = event[:description]
        end

        if event[:host] && event[:port]
          # we got redirected!!!!
          log.info "UPDATE client params (host/port)"
          host, port = event[:host], event[:port]

          if $client.host != host || $client.port != port
            # redirect to new host/port.............
            host, port = event[:host], event[:port] #.fetch_all(:host, :port)
            log.info "REDIRECT CLIENT TO #{host}:#{port}"
            $client.command('drop')
            # $client.comms_thread.kill #quit! # kill threads?
            @visited.push({host: host, port: port})
            sleep 0.2
            # $client.quit!
            $client = Vico::Client.new(host: host, port: port)
            #event[:host], port: event[:port])
            connect_client!
          end
          # need to reboot client, would be simpler if it was another obj rather than THIS one :/
        end
      rescue
        $stdout.puts $!
        log.error "encountered exception handling event #{event}"
        log.error $!
      end

      def connect_client!
        $client.connect!
        $client.poll(&method(:listen))
        $client.command "iam #{user_id}"
        $client.command "look"

        # need to join comms thread....
      end

      def user_id
        @user_id ||= "guest#{(rand*1_000).to_i}"
      end

      def engage!
        connect_client!
        @ui_thread = launch_ui!
        @refresh_thread = Thread.new { refresh_loop }
        log.info "starting threads..."
        [  @refresh_thread, @ui_thread ].map(&:join)
      end

      def refresh_loop
        until $client.quit?
          begin
            sleep 0.15
            draw; refresh
          rescue
            log.error $!
          end
        end
      end

      def log
        @logger ||= Logger.new("log/screen.log")
      end

      def launch_ui!
        Thread.new do
          begin
            noecho
            init_screen
            wait_for_keypress until quit?
          rescue
            log.error $!
          ensure
            close_screen
          end
        end
      end

      def wait_for_keypress
        log.info "WAIT FOR KEYPRESS!!!!"
        case getch
        when 'x', 'q' then quit!
        when 'h' then $client.command 'go east'
        when 'k' then $client.command 'go north'
        when 'j' then $client.command 'go south'
        when 'l' then $client.command 'go west'
        when '>' then $client.command 'go down'
        when '<' then up!
        end
      end

      def up!
        return false unless @visited.count > 1

        $client.command 'drop'
        @visited.pop
        last_server = @visited.last
        log.info "---> Dropping back to last server: #{last_server}"
        $client = Vico::Client.new(host: last_server[:host], port: last_server[:port]) #host: last_server[:host, port: port)
        connect_client!
      end

      def draw
        # log.info 'draw!'
        clear
        if @map
          # log.info "DRAW MAP"
          @map.draw
          if @players
            @players.each do |player|
              player.draw(map: @map)
            end

            you = @players.detect(&:you)
            if you
              setpos(4,0)
              addstr("FLYING OVER: #{@map.describe(you.x, you.y)} (#{you.x}, #{you.y})")
            end
          end

          if @space
            setpos(0,0)
            addstr("CURRENT SPACE: #{@space.name}")
          end

          if @description
            setpos(5,0)
            addstr("DESCRIPTION: #{@description}")
          end
        else
          x = cols / 2  # We will center our text
          y = lines / 2
          setpos(y, x)  # Move the cursor to the center of the screen
          addstr("Please wait, connecting to World Server...")
        end
      end
    end
  end
end
