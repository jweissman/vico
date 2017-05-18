module Vico
  module Screen
    class VisualClient < Vico::Client
      include Curses
      attr_accessor :map

      def listen(event)
        if event[:map] && event[:legend] # update map...
          @map = Map.new(field: event[:map], legend: event[:legend])
        end

        if event[:pawns] # update pawn locations...
          log.info "UPDATE players: #{event[:pawns]}"
          @players = event[:pawns].map do |*attrs|
            Player.new(*attrs)
          end
        end

        if event[:world] # update world info
          log.info "UPDATE world / space"
          @space = Space.new(name: event[:world][:name])
        end
      rescue
        $stdout.puts $!
        log.error "encountered exception handling event #{event}"
        log.error $!
      end

      def engage!
        poll(&method(:listen))

        # puts
        # print " what's your name? "
        # @name = 'guest' # $stdin.gets.chomp
        command "iam guest#{(rand*1_000).to_i}" ##@name"
        command "look"

        @ui_thread = launch_ui!
        @refresh_thread = Thread.new { refresh_loop }
        log.info "starting threads..."
        [  @refresh_thread, @comms_thread, @ui_thread ].map(&:join)
      end

      def refresh_loop
        until quit?
          begin
            sleep 0.15
            tick; draw # and draw
            refresh
          rescue
            log.error $!
          end
        end
      end

      def log
        @logger ||= Logger.new("log/screen.log")
      end

      def tick
        # log.info "TICK"
        # puts "inc counter"
        # @counter += 1
      end

      def launch_ui!
        Thread.new do
          begin
            noecho
            init_screen
            wait_for_keypress until quit?
            # nb_lines = lines
            # nb_cols = cols
            # draw until quit?
          ensure
            close_screen
          end
        end
        # $stdout.puts "--- ui launched..."
      end

      def wait_for_keypress
        case getch
        when 'x', 'q' then quit!
        when 'h' then command 'go east'
        when 'k' then command 'go north'
        when 'j' then command 'go south'
        when 'l' then command 'go west'
        end
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
              setpos(10,0)
              addstr("FLYING OVER: (#{you.x}, #{you.y})")
            end
          end

          if @space
            setpos(0,0)
            addstr("CURRENT SPACE: #{@space.name}")
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
