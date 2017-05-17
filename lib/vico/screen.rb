require 'logger'
module Vico
  class Map
    include Curses

    attr_reader :legend, :field

    def initialize(field:, legend:)
      @field = field
      @legend = legend
    end

    def height
      @field.length
    end

    def width
      @field[0].length
    end

    def center_x
      cols / 2
    end

    def center_y
      lines / 2
    end

    def origin_x
      center_x - width/2
    end

    def origin_y
      center_y - height/2
    end

    def draw
      return unless @field
      setpos(1,0)
      addstr("MAP SIZE: #{width}x#{height}")
      x0, y0 = origin_x, origin_y
      (0..width-1).each do |x|
        (0..height-1).each do |y|
          figure = figure_at(x,y)
          ax,ay = x + x0, y + y0
          setpos(ay,ax)
          addstr(figure)
        end
      end
      refresh
    end

    def figure_at(x,y)
      figure_for(value_at(x,y))
    end

    def value_at(x,y)
      @field[y][x]
    end

    def figure_for(value)
      case @legend[value].to_sym
      when :water then '~'
      when :land then '='
      when :city then '*'
      else '?'
      end
    end
  end

  class Player
    include Curses
    attr_accessor :x, :y, :name
    def initialize(name:, x:, y:, you:)
      @name = name
      @x, @y = x, y
      @you = you
    end

    def draw(map:)
      x0 = x + map.origin_x
      y0 = y + map.origin_y

      setpos(y0, x0)
      addstr figure

      setpos(y0 + 1, x0 - name.length/2) #, y+1)
      addstr name
    end

    def figure
      @you ? '@' : '^'
    end
  end

  class Screen < Client
    include Curses

    def engage!
      poll do |event|
        if event[:map] # update map...
          @map = Map.new(field: event[:map], legend: event[:legend])
        end

        if event[:pawns] # update pawn locations...
          log.info "UPDATE players: #{event[:pawns]}"
          @players = event[:pawns].map do |*attrs|
            Player.new(*attrs)
          end
        end

        if event[:world] # update world info
          log.info "UPDATE world"
          @world = World.new(name: event[:world][:name])
        end
      end

      puts
      print " what's your name? "
      @name = $stdin.gets.chomp
      command "iam #@name"

      command "look"

      @ui_thread = launch_ui!

      # refresh proces...
      @refresh_thread = Thread.new do
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

      # @pawn = Pawn.new(name: "Bob")

      # log.info "starting threads..."
      [  @refresh_thread, @comms_thread, @ui_thread ].map(&:join)
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
        end
        if @world
          setpos(0,0)
          addstr("WORLD: #{@world.name}")
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
