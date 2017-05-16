require 'logger'
module Vico
  module Swearing
    module Helpers
    end

    class Component
      include Curses
    end

    class Application
      include Curses
    end
  end

  class Map < Swearing::Component
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

    def draw
      return unless @field
      # draw_centered(figure: field_map)_
      cx = cols / 2  # We will center our text
      cy = lines / 2

      y0, x0 = cy - height/2, cx - width/2

      (0..width-1).each do |x|
        (0..height-1).each do |y|
          figure = figure_for(@field[y][x])
          ax,ay = x + x0, y + y0
          setpos(ay,ax)
          addstr(figure)
        end
      end
      refresh
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

  class Screen < Client
    include Curses

    def engage!
      poll do |event|
        # log.info "GOT EVENT: #{event}"
        # $stdout.puts event
        if event[:map]
          @map = Map.new(field: event[:map], legend: event[:legend])
          # puts "---> GOT MAP #{@map.legend}"
          # puts "---> GOT MAP #{@map.field}"
          #$stdout.puts "===> GOT MAP: #{event['map']}"
        end
      end

      puts
      print " what's your name? "
      name = $stdin.gets.chomp
      command "iam #{name}"

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
      when 'h' then log.info 'east'
      when 'k' then log.info 'north'
      when 'j' then log.info 'south'
      when 'l' then log.info 'west'
      end
    end

    def draw
      # log.info 'draw!'
      clear
      if @map
        # log.info "DRAW MAP"
        @map.draw
      else
        x = cols / 2  # We will center our text
        y = lines / 2
        setpos(y, x)  # Move the cursor to the center of the screen
        addstr("Please wait, connecting to World Server...")
      end
    end
  end
end
