module Vico
  # first client!!
  class Text < Client
    def initialize
      puts "---> Text would connect to local world server..."
      super
    end

    def prompt; "vico> " end

    def engage!
      th = poll do |event|
        $stdout.puts event[:description]
      end

      begin
        while !quit?
          sleep 0.05
          puts
          msg = Readline.readline(prompt, true)
          if msg
            cmd = msg.chomp
            if cmd == 'quit' or cmd == 'exit'
              quit!
            else
              command(cmd) #msg.chomp)
            end
          end
        end
      rescue => ex
        $stdout.puts ex.message
        $stdout.puts ex.backtrace
      end

      th.join
    # ensure
    #   @socket.close
    end
  end
end
