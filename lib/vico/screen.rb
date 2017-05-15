module Vico
  class Screen < Client
    include Curses

    def engage!
      poll do |event|
        # $stdout.puts event
        if event['map']
          @map = event['map']
          #$stdout.puts "===> GOT MAP: #{event['map']}"
        end
      end

      command "look"
      @ui_thread = launch_ui!

      [ @ui_thread, @comms_thread ].map(&:join)

      # $stdout.puts "---> Engagement complete..."
    end

    def launch_ui!
      Thread.new do
        begin
          init_screen
          # nb_lines = lines
          # nb_cols = cols
          draw until quit?
        ensure
          close_screen
        end
      end
      # $stdout.puts "--- ui launched..."
    end

    def draw
      x = cols / 2  # We will center our text
      y = lines / 2
      setpos(y, x)  # Move the cursor to the center of the screen
      if @map
        addstr(@map.to_s)
        refresh
        case getch
        when 'x', 'q' then quit!
        # when 'k' then north
        end
        # if getch == 'x'  # Waiting for a pressed key to exit
        #   quit!
        # end
      else
        addstr("Connecting to vico server...") #(@map.to_s || "Hello World")  # Display the text
      end
    end

  end
end
